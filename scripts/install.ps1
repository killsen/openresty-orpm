﻿# 引入工具库
. $PSScriptRoot\utils.ps1

# 修改版本
function set_lib_ver($author, $lib, $ver) {

    $root = get_root_path
    if (-not $root) { return }

    $conf = Get-Content "$root/.openrestyrc" | ConvertFrom-JSON
    if (-not $conf) { $conf = @{} }

    $old_ver = $conf.lua_resty_libs.("$author/$lib")
    if ($old_ver -eq "$ver") { return }  # 版本一致退出

    if ( -not $conf.lua_resty_libs ) {
        $conf | Add-Member "lua_resty_libs" @{ "$author/$lib" = "$ver" } -Force

    } elseif ( $old_ver ) {
        $conf.lua_resty_libs.("$author/$lib") = "$ver"

    } else {
        $conf.lua_resty_libs | Add-Member "$author/$lib" "$ver" -Force
    }

    $conf | ConvertTo-Json | Set-Content "$root/.openrestyrc"

}

# 安装
function install( $author_lib_ver ) {

    Write-Host "$author_lib_ver" -ForegroundColor Blue

    $root = get_root_path

    if (-not $root) {
        Write-Host ".openrestyrc 文件不存在" -ForegroundColor Red
        return
    }

    $pattern = "([\w-]+)/([\w-]+)@([\w-.]+)"

    if (-not ($author_lib_ver -match $pattern)) {
        Write-Host "author/lib@ver not match: $author_lib_ver"
        return
    }

    $author = $Matches[1]
    $lib    = $Matches[2]
    $ver    = $Matches[3]

    $url    = "https://github.com/$author/$lib/archive/refs/tags/$ver.zip"
    $path   = "$root/.openresty/lua-resty-libs/$author/$lib"
    $file   = "$path/$ver.zip"
    $temp   = "$path/$ver"

    if ( -not (Test-Path $path) ) {
        New-Item -Path $path -ItemType Directory | Out-Null        # 创建目录
    }

    # 下载文件并解压
    $ok = download_expand $url $file $temp $true
    if (-not $ok) { return }

    # 找到 lib/resty 目录并拷贝文件到 nginx/resty 目录
    $resty = get_resty_path $temp
    if (-not $resty) { return }

    # 创建 nginx/resty 目录
    if (-not (Test-Path $root/nginx/resty)) {
        New-Item -Path $root/nginx/resty -ItemType Directory | Out-Null
    }

    Copy-Item -Path $resty/* -Destination $root/nginx/resty -Recurse -Force

    # 修改版本
    set_lib_ver $author $lib $ver

}