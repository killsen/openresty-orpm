# 引入工具库
. $PSScriptRoot\utils.ps1
. $PSScriptRoot\install_luarocks.ps1

# 安装 LuaRocks 库
function Install-LuaRocksLib() {
    Param (
        [Parameter(Position = 0, Mandatory = $true )] [string] $author,
        [Parameter(Position = 1, Mandatory = $true )] [string] $lib,
        [Parameter(Position = 2, Mandatory = $false)] [string] $ver
    )

    $rocks = install_luarocks
    if (-not $rocks) { return }

    Write-Host "$author/$lib" -ForegroundColor Yellow -NoNewline

    try {
        $logs = & $rocks install $lib
        foreach ($log in $logs) {
            if ($log -match "$lib (([\w-.]+)) is now installed in") {
                $ver = $Matches[1]
                Write-Host "@$ver" -ForegroundColor Blue
                return $ver
            }
        }
    } catch {}

    Write-Host " (安装失败) " -ForegroundColor Red
}

# 安装 Github 库
function Install-GithubLib() {
    Param (
        [Parameter(Position = 0, Mandatory = $true )] [string] $author,
        [Parameter(Position = 1, Mandatory = $true )] [string] $lib,
        [Parameter(Position = 2, Mandatory = $false)] [string] $ver,
        [Parameter(Mandatory = $true)] [string] $root,
        [Parameter(Mandatory = $true)] [string] $orpm,
        [switch] $PeerDeps
    )

    if ($PeerDeps) {
        Write-Host "  + " -NoNewline
    }
    Write-Host "$author/$lib" -ForegroundColor Yellow -NoNewline

    if (-not $ver -or $ver -eq "last") {
        $ver = Get-LastLibVer $author $lib  # 获取最新版本
        if (-not $ver) {
            Write-Host " (获取版本失败) " -ForegroundColor Red
            return
        }
    }

    Write-Host "@$ver" -ForegroundColor Blue

    if ($ver -eq "main" -or $ver -eq "master") {
        $url   = "https://github.com/$author/$lib/archive/refs/heads/$ver.zip"
        $force = $true
    } else {
        $url   = "https://github.com/$author/$lib/archive/refs/tags/$ver.zip"
        $force = $false
    }

    $path = "$orpm/libs/$author/$lib"
    $file = "$path/$ver.zip"
    $temp = "$path/$ver"

    if (Test-Path $temp) {
        # 删除临时目录
        Remove-Item -Path $temp -Recurse -Force -ErrorAction Stop
    }

    make_path $path
    make_path $temp

    # 下载文件并解压
    $ok = download_expand $url $file $temp $force
    if (-not $ok) { return }

    # 安装 lua_types
    $lua_types = get_child_path $temp "lua_types"
    if ($lua_types) {
        $dist = "$root/lua_types"; make_path $dist
        Copy-Item -Path $lua_types/* -Destination $dist -Recurse -Force
        return $ver  # lua_types 安装成功直接退出
    }

    # 安装 32bit 及 64bit 预编译 clib
    $clib_installed = $false
    foreach ($bit in ("32bit", "64bit")) {
        $lua_modules = get_lua_modules $temp $bit
        if (-not $lua_modules) { continue }
        $clib = "$root/.rocks/$bit/lua_modules/clib"; make_path $clib
        $lua  = "$root/.rocks/$bit/lua_modules/lua" ; make_path $lua
        Copy-Item -Path $lua_modules/clib/* -Destination $clib -Recurse -Force
        Copy-Item -Path $lua_modules/lua/*  -Destination $lua  -Recurse -Force
        $clib_installed = $true
    }
    if ($clib_installed) {
        return $ver  # clib 安装成功直接退出
    }

    $lib_conf = get_lib_conf $temp

    # 安装 openresty-appx 框架
    $lua_modules = get_child_path $temp "lua_modules"
    if ($lua_modules) {
        $temp_appx  = "$lua_modules/app"
        $temp_nginx = get_child_path $temp "nginx"
        $dist_appx  = "$root/lua_modules/app"
        $dist_nginx = "$root/nginx"

        # 存在 lua_modules/app 及 nginx 目录
        if ((Test-Path $temp_appx) -and $temp_nginx) {
            if (Test-Path $dist_appx) {
                Remove-Item -Path $dist_appx -Recurse -Force -ErrorAction Stop
            }
            make_path $dist_appx
            Copy-Item -Path $temp_appx/* -Destination $dist_appx -Recurse -Force

            if (Test-Path $dist_nginx) {
                $confirm = Read-Host "  ? nginx 目录已经存在, 如果要覆盖请输入 NGINX"
                if ($confirm -eq "NGINX") {
                    Write-Host "  + nginx 目录已更新" -ForegroundColor Red
                    Copy-Item -Path $temp_nginx/* -Destination $dist_nginx -Recurse -Force
                }
            } else {
                make_path $dist_nginx
                Copy-Item -Path $temp_nginx/* -Destination $dist_nginx -Recurse -Force
            }

            return $ver, $lib_conf  # appx 安装成功直接退出并返回包信息
        }

    }

    # 安装 resty
    $resty = get_resty_path $temp
    if ($resty) {
        $dist = "$root/lua_modules/resty"; make_path $dist
        Copy-Item -Path $resty/* -Destination $dist -Recurse -Force
        return $ver # resty 安装成功直接退出
    }

    # 复制 lua 或者 lib 目录
    foreach ($src in ("lua", "lib")) {
        $src_path = get_child_path $temp $src
        if (-not $src_path) { continue }

        $dist32 = "$root/.rocks/32bit/lua_modules/lua"; make_path $dist32
        $dist64 = "$root/.rocks/64bit/lua_modules/lua"; make_path $dist64
        Copy-Item -Path $src_path/* -Destination $dist32 -Recurse -Force
        Copy-Item -Path $src_path/* -Destination $dist64 -Recurse -Force

        return $ver
    }

    if ($PeerDeps) {
        Write-Host "    " -NoNewline
    }
    Write-Host "未检出到以下目录 lua, lib, resty, 32bit, 64bit" -ForegroundColor Red

}

# 清空已安装列表
$Global:INSTLLED = @{}

function install( $author_lib_ver, $isdev ) {

    $root = get_root_path
    $orpm = get_orpm_path

    if (-not $root) {
        Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
        return
    }

    # 初始化 .rocks 目录
    init_rocks_path

    $author_lib_ver = $author_lib_ver.ToLower()
    $pattern = "([\w-]+)/([\w-]+)(?:@([\w-.]+))?"

    if (-not ($author_lib_ver -match $pattern)) {
        Write-Host "author/lib@ver? not match: $author_lib_ver"
        return
    }

    $author, $lib, $ver = $Matches[1], $Matches[2], $Matches[3]
    if ($Global:INSTLLED["$author/$lib"]) { continue }  # 不重复安装

    if ($author -eq "rocks") {
         # 安装 LuaRocks 库
        $ver = Install-LuaRocksLib $author $lib $ver
    } else {
        # 安装 Github 库
        $ver, $lib_conf = Install-GithubLib $author $lib $ver -root $root -orpm $orpm
    }

    if (-not $ver) { return }

    $Global:INSTLLED["$author/$lib"] = $true
    Set-LibVer $author $lib $ver $isdev # 修改版本

    $libs = $lib_conf.libs
    if (-not $libs) { return }

    foreach($item in $libs.PSObject.Properties)
    {
        $author_lib, $ver = $item.Name, $item.Value
        $pattern = "([\w-]+)/([\w-]+)"

        if (-not ($author_lib -match $pattern)) { continue }
        $author, $lib = $Matches[1], $Matches[2]

        if ( $author -eq "rocks" ) { continue }
        if ( $ver.IndexOf("#") -ne -1 ) { continue }
        if ( $Global:INSTLLED["$author/$lib"] ) { continue }  # 不重复安装

        $ver = Install-GithubLib $author $lib $ver -root $root -orpm $orpm -PeerDeps
        if (-not $ver) { return }

        $Global:INSTLLED["$author/$lib"] = $true
        Set-LibVer $author $lib $ver $isdev
    }

}

# 获取最新版本
function Get-LastLibVer() {
    Param (
        [Parameter(Position = 0, Mandatory = $true)] [string] $author,
        [Parameter(Position = 1, Mandatory = $true)] [string] $lib
    )
    try {
        $url   = "https://github.com/$author/$lib/tags"
        $regx  = "archive/refs/tags/(v?[\d.]+)\.zip"
        $links = (Invoke-WebRequest -Uri "$url").Links | Where-Object { $_.href -match "$regx" }
        if ($links[0].href -match $regx) {
            return $Matches[1]
        }
    } catch {}
}

# 修改版本
function Set-LibVer() {
    Param (
        [Parameter(Position = 0, Mandatory = $true )] [string] $author,
        [Parameter(Position = 1, Mandatory = $true )] [string] $lib,
        [Parameter(Position = 2, Mandatory = $true )] [string] $ver,
        [Parameter(Position = 3, Mandatory = $false)] [string] $isdev
    )

    $root = get_root_path
    if (-not $root) { return }

    $conf = get_orpm_conf
    if (-not $conf) { return }

    $key = "$author/$lib"

    if ($isdev -eq "-d") {
        if ($conf.devs[$key] -eq $ver) { return }
        $conf.devs[$key] = $ver
        $conf.libs.remove($key)
    } else {
        if ($conf.libs[$key] -eq $ver) { return }
        $conf.libs[$key] = $ver
        $conf.devs.remove($key)
    }

    $conf | ConvertTo-Json | Set-Content "$root/.orpmrc" | Out-Null

    Start-Sleep -Milliseconds 50  # 延时 50 毫秒, 避免写文件冲突
}
