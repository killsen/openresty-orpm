# 引入工具库
. $PSScriptRoot\utils.ps1
. $PSScriptRoot\install_openresty.ps1
. $PSScriptRoot\install_mingw.ps1

function install_luarocks() {

    $root = get_root_path
    $orpm = get_orpm_path
    $conf = get_orpm_conf

    if (-not $root) {
        Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
        return
    }

    $ver = $conf.luarocks_ver
    if (-not $ver) { $ver = "3.9.1" }

    if ($conf.arch -eq "64bit" -or $conf.arch -eq "64") {
        $bit = "64"
    } else {
        $bit = "32"
    }

    $name = "luarocks-$ver-windows-$bit"
    $url  = "http://luarocks.github.io/luarocks/releases/$name.zip"
    $file = "$orpm/luarocks/$name.zip"
    $path = "$orpm/luarocks"

    make_path $path

    $luarocks_path = "$path/$name"
    $luarocks_exe  = "$luarocks_path/luarocks.exe"

    if (-not (Test-Path $luarocks_exe)) {
        # 下载文件并解压
        download_expand $url $file $path
        if (-not (Test-Path $luarocks_exe)) {
            return
        }
    }

    $openresty = install_openresty
    if (-not $openresty) { return }

    $mingw_bin = install_mingw
    if (-not $mingw_bin) { return }

    make_path "$root/.rocks"

    $luarocks_config = "$root/.rocks/config.lua"
    $ENV:LUAROCKS_CONFIG = "$luarocks_config"

    $env_path = $ENV:PATH -replace "$mingw_bin;", ""
    $ENV:PATH = "$mingw_bin;$env_path"

 $CONF = @"

rocks_trees = {
    {
        root    = [[$root/.rocks]],
        bin_dir = [[$root/.rocks/bin]],
        lib_dir = [[$root/nginx/clib]],
        lua_dir = [[$root/nginx/lua]],
    },
}

lua_interpreter = [[luajit.exe]]
lua_version     = "5.1"
verbose         = false

variables = {
    LUA_BINDIR  = [[$openresty]],
    LUA_DIR     = [[$openresty]],
    LUALIB      = [[lua51.dll]],
    MSVCRT      = [[m]],   -- make MinGW use MSVCRT.DLL as runtime
    MAKE        = [[$mingw_bin/make.exe]],
    CC          = [[$mingw_bin/gcc.exe]],
    LD          = [[$mingw_bin/gcc.exe]],
    RC          = [[$mingw_bin/windres.exe]],
    AR          = [[$mingw_bin/ar.exe]],
    RANLIB      = [[$mingw_bin/ranlib.exe]],
}
"@

    Set-Content "$luarocks_config" $CONF

    return $luarocks_exe

}
