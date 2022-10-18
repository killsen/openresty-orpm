# 引入工具库
. $PSScriptRoot\utils.ps1

function get_nginx_conf() {
@"
worker_processes  1;

events {
    worker_connections  1024;
}

http {

    lua_package_path "`${prefix}?.lua;`${prefix}?/init.lua;`${prefix}lua/?.lua;`${prefix}lua/?/init.lua;;";
    lua_package_cpath "`${prefix}clib/?.dll;`${prefix}clib/?/?.dll;`${prefix}?.dll;`${prefix}clib/?.so;`${prefix}clib/?/?.so;`${prefix}?.so;;";

    client_body_temp_path      	 	temp/client_body_temp;
    fastcgi_temp_path           	temp/fastcgi_temp;
    proxy_temp_path             	temp/proxy_temp;
    scgi_temp_path              	temp/scgi_temp;
    uwsgi_temp_path             	temp/uwsgi_temp;

    server {
        listen       80;
        server_name  localhost;
        location / {
            content_by_lua_block {
                ngx.say "Hello, OpenResty!"
            }
        }
    }
}
"@
}

# 安装 openresty
function install_openresty() {

    $root = get_root_path
    $orpm = get_orpm_path

    if (-not $root) {
        Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
        return
    }

    try {
        $conf = Get-Content "$root/.orpmrc" | ConvertFrom-JSON
        if (-not $conf) { $conf = @{} }
    } catch {
        Write-Host ".orpmrc 文件读取失败" -ForegroundColor Red
        return
    }

    # 关闭 nginx 进程
    Get-Process -Name "nginx*" | Stop-Process

    $openresty_ver = $conf.openresty_ver

    if (-not $openresty_ver) {
        $down = "https://openresty.org/download"
        $link = (Invoke-WebRequest -Uri "$down").Links |
            Where-Object {$_.href -like "$down/openresty-*-win32.zip"}

        if ($link[0].href -match "openresty-(.+)-win32.zip") {
            $openresty_ver = $Matches[1]
        } else {
            Write-Host "openresty_ver 未定义" -ForegroundColor Red
            return
        }

        if ($null -eq $conf.openresty_ver) {
            $conf | Add-Member "openresty_ver" $openresty_ver -Force
        } else {
            $conf.openresty_ver = $openresty_ver
        }

        $conf | ConvertTo-Json | Set-Content "$root/.orpmrc"
    }

    $nginx              = "$root/nginx"
    $openresty          = "$orpm/openresty"
    $openresty_win32    = "openresty-$openresty_ver-win32"
    $nginx_exe          = "$openresty/$openresty_win32/nginx.exe"
    $lualib_link        = "$openresty/$openresty_win32/lualib"
    $luajit_link        = "$openresty/$openresty_win32/lua/jit"

    make_path $openresty

    if ( -not (Test-Path $nginx_exe) ) {
        $url  = "https://openresty.org/download/$openresty_win32.zip"
        $file = "$openresty/$openresty_win32.zip"

        # 下载文件并解压
        $ok = download_expand $url $file $openresty $false
        if (-not $ok) { return }
    }

    make_path $nginx
    make_path $nginx/conf
    make_path $nginx/temp
    make_path $nginx/logs
    make_link $nginx/lualib  $lualib_link
    make_link $nginx/lua/jit $luajit_link

    if (-not (Test-Path "$nginx/conf/nginx.conf")) {
        $conf = get_nginx_conf
        Set-Content "$nginx/conf/nginx.conf" $conf
    }

    return "$openresty/$openresty_win32"

}
