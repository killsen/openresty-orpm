# 引入工具库
. $PSScriptRoot\utils.ps1
. $PSScriptRoot\install_openresty.ps1
. $PSScriptRoot\install_mingw.ps1

function install_luarocks() {

    $root = get_root_path

    if (-not $root) {
        Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
        return
    }

    $url  = "https://luarocks.github.io/luarocks/releases/luarocks-3.9.1-windows-32.zip"
    $file = "$root/.orpm/luarocks/luarocks-3.9.1-windows-32.zip"
    $path = "$root/.orpm/luarocks/"

    make_path $path

    # 下载文件并解压
    $ok = download_expand $url $file $path
    if (-not $ok) { return }

    $lua_dir = install_openresty
    if (-not $lua_dir) { return }

    $mingw32_bin = install_mingw
    if (-not $mingw32_bin) { return }

    $luarocks_path = "$path/luarocks-3.9.1-windows-32/"
    $luarocks_exe  = "$luarocks_path/luarocks.exe"
    $luarocks_conf = "$luarocks_path/config.lua"
    $env:LUAROCKS_CONFIG = "$luarocks_conf"

 $CONF = @"

rocks_trees = {
    {
        root    = [[$luarocks_path]],
        bin_dir = [[$luarocks_path/bin]],
        lib_dir = [[$root/nginx/clib]],
        lua_dir = [[$root/nginx/lua]],
    },
}

lua_interpreter = [[luajit.exe]]
lua_version     = "5.1"
verbose         = false

variables = {
    LUA_BINDIR  = [[$lua_dir]],
    LUA_DIR     = [[$lua_dir]],
    LUALIB      = [[lua51.dll]],
    MSVCRT      = [[m]],   -- make MinGW use MSVCRT.DLL as runtime
    MAKE        = [[$mingw32_bin/make.exe]],
    CC          = [[$mingw32_bin/gcc.exe]],
    LD          = [[$mingw32_bin/gcc.exe]],
    RC          = [[$mingw32_bin/windres.exe]],
    AR          = [[$mingw32_bin/ar.exe]],
    RANLIB      = [[$mingw32_bin/ranlib.exe]],
}
"@

    Set-Content "$luarocks_path/config.lua" $CONF

    return $luarocks_exe

}
