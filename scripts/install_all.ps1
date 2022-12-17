# 引入工具库
. $PSScriptRoot\utils.ps1
. $PSScriptRoot\install_openresty.ps1
. $PSScriptRoot\install_mingw.ps1
. $PSScriptRoot\install_luarocks.ps1
. $PSScriptRoot\install.ps1

$root = get_root_path
$orpm = get_orpm_path
$conf = get_orpm_conf

Write-Host

if ($root) {
    Write-Host "workspace: " -ForegroundColor Yellow -NoNewline
    Write-Host "$root"       -ForegroundColor Blue
    Write-Host "orpm home: " -ForegroundColor Yellow -NoNewline
    Write-Host "$orpm"       -ForegroundColor Blue
} else {
    Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
    Write-Host
    return
}

# 关闭 openresty 进程
Get-Process -Name "openresty*" | Stop-Process -PassThru

# 初始化 .rocks 目录
init_rocks_path

Write-Host
Write-Host "install openresty: " -ForegroundColor Yellow
$openresty = install_openresty
if (-not $openresty) { return }
Write-Host $openresty -ForegroundColor Blue

# Write-Host
# Write-Host "install mingw: " -ForegroundColor Yellow
# $mingw32_bin = install_mingw
# if (-not $mingw32_bin) { return }
# Write-Host $mingw32_bin -ForegroundColor Blue

# Write-Host
# Write-Host "install luarocks: " -ForegroundColor Yellow
# $luarocks_exe = install_luarocks
# if (-not $luarocks_exe) { return }
# Write-Host $luarocks_exe -ForegroundColor Blue

Write-Host
Write-Host "install libs: " -ForegroundColor Yellow
Write-Host "-------------------------------------------------"

$libs = $conf.libs
$devs = $conf.devs

if (-not $libs.count -and -not $devs.count) {
    Write-Host "no libs installed" -ForegroundColor Blue
}

# 排除忽略的 libs
$Global:INSTLLED = get_ignored_libs

function _install ($author_lib, $ver, $isdev) {
    $pattern = "([\w-]+)/([\w-]+)"
    if (-not ($author_lib -match $pattern)) { return }
    $author, $lib = $Matches[1], $Matches[2]

    if ( $author -eq "rocks" ) { return }
    if ($ver.IndexOf("#") -ne -1 ) { return }

    install "$author_lib@$ver" $isdev
}

foreach($author_lib in $libs.keys) {
    $ver = $libs[$author_lib]
    _install $author_lib $ver
}

foreach($author_lib in $devs.keys) {
    $ver = $devs[$author_lib]
    _install $author_lib $ver "-d"
}

# 排除忽略的 libs
$Global:INSTLLED = get_ignored_libs

Write-Host "-------------------------------------------------"
Write-Host
