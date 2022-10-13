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

    try {
        $conf = Get-Content "$root/.openrestyrc" | ConvertFrom-JSON
    } catch { }

    if (-not $conf) { $conf = @{} }

    if (-not $conf.lua_resty_libs) {
        $conf | Add-Member "lua_resty_libs" @{ "$author/$lib" = "$ver" } -Force
    } else {
        $conf.lua_resty_libs | Add-Member "$author/$lib" "$ver" -Force
    }

    $conf | ConvertTo-Json | Set-Content "$root/.openrestyrc"

    if ( -not (Test-Path $path) ) {
        New-Item -Path $path -ItemType Directory | Out-Null        # 创建目录
    }

    if (-not (Test-Path $file)) {
        try {
            wget.exe "$url" -O "$file"                              # wget下载
        } catch {
            Invoke-WebRequest -Uri $url -OutFile $file              # 下载文件
        }
    }

    if (Test-Path $temp) {
        Remove-Item -Path $temp -Recurse -Force -ErrorAction Stop   # 删除临时目录
    }

    try {
        7z.exe x "$file" -o"$temp" -y -aoa  | Out-Null              # 7zip解压
    } catch {
        Expand-Archive -Path $file -DestinationPath $temp -Force    # 解压文件
    }

    # 找到 lib/resty 目录并拷贝文件到 nginx/resty 目录
    $resty = get_resty_path $temp
    if ($resty) {
        Copy-Item -Path $resty/* -Destination $root/nginx/resty -Recurse -Force
    }

}
