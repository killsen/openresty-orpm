# 引入工具库
. $PSScriptRoot\utils.ps1

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

    make_path $root/lua_modules
    make_link $root/lua_modules/lualib      $lualib_link
    make_link $root/lua_modules/lualib/jit  $luajit_link

    if (-not (Test-Path "$nginx/conf/nginx.conf")) {
        $conf = Get-Content "$PSScriptRoot/../template/default/nginx/conf/nginx.conf"
        Set-Content "$nginx/conf/nginx.conf" $conf
    }

    return "$openresty/$openresty_bit"

}
