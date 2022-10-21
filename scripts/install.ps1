# 引入工具库
. $PSScriptRoot\utils.ps1
. $PSScriptRoot\install_luarocks.ps1

# 修改版本
function set_lib_ver($author, $lib, $ver) {

    $root = get_root_path
    if (-not $root) { return }

    $conf = Get-Content "$root/.orpmrc" | ConvertFrom-JSON
    if (-not $conf) { $conf = @{} }

    $old_ver = $conf.libs.("$author/$lib")
    if ($old_ver -eq "$ver") { return }  # 版本一致退出

    if ( -not $conf.libs ) {
        $conf | Add-Member "libs" @{ "$author/$lib" = "$ver" } -Force

    } elseif ( $old_ver ) {
        $conf.libs.("$author/$lib") = "$ver"

    } else {
        $conf.libs | Add-Member "$author/$lib" "$ver" -Force
    }

    $conf | ConvertTo-Json | Set-Content "$root/.orpmrc"

}

# 获取版本
function get_lib_ver($lib) {
    try {
        $url   = "https://github.com/$lib/tags"
        $regx  = "archive/refs/tags/(v?[\d.]+)\.zip"
        $links = (Invoke-WebRequest -Uri "$url").Links | Where-Object { $_.href -match "$regx" }
        if ($links[0].href -match "$regx") {
            return $Matches[1]
        }
    } catch {}
}

# 安装
function install( $author_lib_ver ) {

    $root = get_root_path
    $orpm = get_orpm_path

    if (-not $root) {
        Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
        return
    }

    $author_lib_ver = $author_lib_ver.ToLower()
    $pattern = "(([\w-]+)/)?([\w-]+)(@([\w-.]+))?"

    if (-not ($author_lib_ver -match $pattern)) {
        Write-Host "author/lib@ver not match: $author_lib_ver"
        return
    }

    $author = $Matches[2]
    $lib    = $Matches[3]
    $ver    = $Matches[5]

    if (-not $author) { $author = "rocks" }

    if ($author -eq "rocks") {
        $rocks = install_luarocks
        if (-not $rocks) { return }
        try {
            Write-Host "$author/$lib" -ForegroundColor Yellow -NoNewline
            $ok = $false
            & $rocks install "$lib" | ForEach-Object {
                if ($_ -match "$lib (([\w-.]+)) is now installed in") {
                    $ver = $Matches[1]
                    Write-Host "@$ver" -ForegroundColor Blue
                    set_lib_ver $author $lib $ver
                    $ok = $true
                }
            }
            if (-not $ok) {
                Write-Host " (安装失败) " -ForegroundColor Red
            }
        } catch {}
        return
    }

    Write-Host "$author/$lib" -ForegroundColor Yellow -NoNewline

    if (-not $ver -or $ver -eq "last") {
        $ver = get_lib_ver "$author/$lib"  # 获取版本
        if (-not $ver) {
            Write-Host " (获取版本失败) " -ForegroundColor Red
            return
        }
    }

    Write-Host "@$ver" -ForegroundColor Blue

    $url    = "https://github.com/$author/$lib/archive/refs/tags/$ver.zip"
    $path   = "$orpm/libs/$author/$lib"
    $file   = "$path/$ver.zip"
    $temp   = "$path/$ver"

    make_path $path
    make_path $temp

    # 下载文件并解压
    $ok = download_expand $url $file $temp $true
    if (-not $ok) { return }

    # 复制 resty
    $resty = get_resty_path $temp
    if ($resty) {
        $dist = "$root/lua_modules/resty"
        make_path $dist
        Copy-Item -Path $resty/* -Destination $dist -Recurse -Force
    }

    # 复制 32bit 及 64bit 预编译 clib
    foreach ($bit in ("32bit", "64bit")) {
        $lua_modules = get_lua_modules $temp $bit
        if (-not $lua_modules) { continue }

        $clib = "$root/.rocks/$bit/lua_modules/clib"
        $lua  = "$root/.rocks/$bit/lua_modules/lua"

        make_path $clib
        make_path $lua

        Copy-Item -Path $lua_modules/clib/* -Destination $clib -Recurse -Force
        Copy-Item -Path $lua_modules/lua/*  -Destination $lua  -Recurse -Force
    }

    # 修改版本
    set_lib_ver $author $lib $ver

}
