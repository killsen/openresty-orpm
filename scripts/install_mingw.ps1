# 引入工具库
. $PSScriptRoot\utils.ps1

function install_mingw() {

    $root = get_root_path

    if (-not $root) {
        Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
        return
    }

    $url  = "https://github.com/niXman/mingw-builds-binaries/releases/download/12.2.0-rt_v10-rev0/i686-12.2.0-release-posix-dwarf-rt_v10-rev0.7z"
    $file = "$root/.orpm/mingw/mingw32.7z"
    $path = "$root/.orpm/mingw/"

    $mingw32_bin = "$path/mingw32/bin"

    if (Test-Path "$mingw32_bin/gcc.exe") {
        return $mingw32_bin
    }

    make_path $path

    # 下载文件并解压
    $ok = download_expand $url $file $path
    if (-not $ok) { return }

    return $mingw32_bin

}
