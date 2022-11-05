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

    # 关闭 openresty 进程
    Get-Process -Name "openresty*" | Stop-Process

    $ver = $conf.openresty_ver
    if (-not $ver) { $ver = "1.21.4.1" }

    if ($conf.arch -eq "64bit" -or $conf.arch -eq "64") {
        $bit = "64"
    } else {
        $bit = "32"
    }

    $openresty          = "$orpm/openresty"
    $openresty_bit      = "openresty-$ver-win$bit"
    $nginx_exe          = "$openresty/$openresty_bit/nginx.exe"
    $openresty_exe      = "$openresty/$openresty_bit/openresty.exe"
    $lualib_link        = "$openresty/$openresty_bit/lualib"
    $luajit_link        = "$openresty/$openresty_bit/lua/jit"

    make_path $openresty

    if ( -not (Test-Path $nginx_exe) ) {
        $url  = "https://openresty.org/download/$openresty_bit.zip"
        $file = "$openresty/$openresty_bit.zip"

        # 下载文件并解压
        $ok = download_expand $url $file $openresty
        if (-not $ok -or -not (Test-Path $nginx_exe)) {
            return
        }
    }

    # 复制 nginx.exe >> openresty.exe
    if (-not (Test-Path $openresty_exe)) {
        Copy-Item -Path $nginx_exe -Destination $openresty_exe | Out-Null
    }

    make_path $root/lua_modules
    make_link $root/lua_modules/lualib      $lualib_link
    make_link $root/lua_modules/lualib/jit  $luajit_link

    return "$openresty/$openresty_bit", $openresty_exe

}
