# 引入工具库
. $PSScriptRoot\utils.ps1

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

    if ( -not (Test-Path $file) ) {
        try{
            # wget.exe "$url" -O "$file"                            # wget下载
            Invoke-WebRequest -Uri $url -OutFile $file              # 下载文件
        } catch {
            Write-Host "下载文件失败: " -ForegroundColor Yellow -NoNewline
            Write-Host "$url" -ForegroundColor Red
            return
        }
    }

    if (Test-Path $temp) {
        Remove-Item -Path $temp -Recurse -Force -ErrorAction Stop   # 删除临时目录
    }

    try{
        # 7z.exe x "$file" -o"$temp" -y -aoa  | Out-Null            # 7zip解压
        Expand-Archive -Path $file -DestinationPath $temp -Force    # 解压文件
    } catch {
        Write-Host "解压文件失败: " -ForegroundColor Yellow -NoNewline
        Write-Host "$file" -ForegroundColor Red
        return
    }

    # 找到 lib/resty 目录并拷贝文件到 nginx/resty 目录
    $resty = get_resty_path $temp
    if (-not $resty) { return }

    Copy-Item -Path $resty/* -Destination $root/nginx/resty -Recurse -Force

    try {
        $conf = Get-Content "$root/.openrestyrc" | ConvertFrom-JSON
    } catch { }

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
