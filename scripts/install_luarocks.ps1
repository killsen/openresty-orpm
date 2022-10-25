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

    init_rocks_path  # 初始化 .rocks 目录

    $ver = $conf.luarocks_ver
    if (-not $ver) { $ver = "3.8.0" }

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
        $ok = download_expand $url $file $path
        if (-not $ok -or -not (Test-Path $luarocks_exe)) {
            return
        }
    }

    $openresty = install_openresty
    if (-not $openresty) { return }

    $mingw_bin = install_mingw
    if (-not $mingw_bin) { return }

    $rocks_path = "$root/.rocks/$bit" + "bit"

    $luarocks_config = "$rocks_path/config.lua"
    $ENV:LUAROCKS_CONFIG = "$luarocks_config"

    $env_path = $ENV:PATH -replace "$luarocks_path;", ""
    $ENV:PATH = "$luarocks_path;$env_path"

    $env_path = $ENV:PATH -replace "$mingw_bin;", ""
    $ENV:PATH = "$mingw_bin;$env_path"

    $CONF = @"

rocks_trees = {
    {
        root    = [[$rocks_path]],
        bin_dir = [[$rocks_path/bin]],
        lib_dir = [[$rocks_path/lua_modules/clib]],
        lua_dir = [[$rocks_path/lua_modules/lua]],
    }
}

lua_interpreter = [[luajit.exe]]
lua_version     = "5.1"
verbose         = false
keep_other_versions = false

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
