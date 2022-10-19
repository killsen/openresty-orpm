# 引入工具库
. $PSScriptRoot\utils.ps1

function install_mingw() {

    $root = get_root_path
    $orpm = get_orpm_path
    $conf = get_orpm_conf

    if (-not $root) {
        Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
        return
    }

    $path = "$orpm/mingw"
    make_path $path

    $ver = $conf.mingw_ver
    if (-not $ver) { $ver = "12.2.0" }

    $url = "https://github.com/niXman/mingw-builds-binaries/releases/download/$ver-rt_v10-rev0/"

    if ($conf.arch -eq "64bit" -or $conf.arch -eq "64") {
        $url += "x86_64-$ver-release-posix-seh-rt_v10-rev0.7z"
        $file = "$path/mingw64.7z"
        $mingw_bin = "$path/mingw64/bin"
    } else {
        $url += "i686-$ver-release-posix-dwarf-rt_v10-rev0.7z"
        $file = "$path/mingw32.7z"
        $mingw_bin = "$path/mingw32/bin"
    }

    $gcc_exe = "$mingw_bin/gcc.exe"
    if (-not (Test-Path $gcc_exe)) {
        # 下载文件并解压
        $ok = download_expand $url $file $path
        if (-not $ok -or -not (Test-Path $gcc_exe)) {
            return
        }
    }

    return $mingw_bin

}
