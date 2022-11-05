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

if (-not $libs) {
    Write-Host "no libs installed" -ForegroundColor Blue
}

# 清空已安装列表
$Global:INSTLLED = @{}

foreach($item in $libs.PSObject.Properties)
{
    $author_lib, $ver = $item.Name, $item.Value
    $pattern = "([\w-]+)/([\w-]+)"

    if (-not ($author_lib -match $pattern)) { continue }
    $author, $lib = $Matches[1], $Matches[2]

    if ( $author -eq "rocks" ) { continue }
    if ($ver.IndexOf("#") -ne -1 ) { continue }

    install "$author_lib@$ver"

}

# 清空已安装列表
$Global:INSTLLED = @{}

Write-Host "-------------------------------------------------"
Write-Host
