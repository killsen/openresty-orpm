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
    $conf = get_orpm_conf

    if (-not $root) {
        Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
        return
    }

    # 关闭 nginx 进程
    Get-Process -Name "nginx*" | Stop-Process

    $ver = $conf.openresty_ver
    if (-not $ver) { $ver = "1.21.4.1" }

    if ($conf.arch -eq "64bit" -or $conf.arch -eq "64") {
        $bit = "64"
    } else {
        $bit = "32"
    }

    $nginx              = "$root/nginx"
    $openresty          = "$orpm/openresty"
    $openresty_bit      = "openresty-$ver-win$bit"
    $nginx_exe          = "$openresty/$openresty_bit/nginx.exe"
    $lualib_link        = "$openresty/$openresty_bit/lualib"
    $luajit_link        = "$openresty/$openresty_bit/lua/jit"

    make_path $openresty

    if ( -not (Test-Path $nginx_exe) ) {
        $url  = "https://openresty.org/download/$openresty_bit.zip"
        $file = "$openresty/$openresty_bit.zip"

        # 下载文件并解压
        $ok = download_expand $url $file $openresty $false
        if (-not $ok -or -not (Test-Path $nginx_exe)) {
            return
        }
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

    return "$openresty/$openresty_bit"

}
