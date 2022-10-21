# 引入工具库
. $PSScriptRoot\utils.ps1
. $PSScriptRoot\install_openresty.ps1
. $PSScriptRoot\install_mingw.ps1
. $PSScriptRoot\install_luarocks.ps1
. $PSScriptRoot\install.ps1

$root = get_root_path
$orpm = get_orpm_path
$conf = get_orpm_conf

Clear-Host
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

# 关闭 nginx 进程
Get-Process -Name "nginx*" | Stop-Process -PassThru

Write-Host
Write-Host "install openresty: " -ForegroundColor Yellow
$openresty_win32 = install_openresty
if (-not $openresty_win32) { return }
Write-Host $openresty_win32 -ForegroundColor Blue

Write-Host
Write-Host "install mingw: " -ForegroundColor Yellow
$mingw32_bin = install_mingw
if (-not $mingw32_bin) { return }
Write-Host $mingw32_bin -ForegroundColor Blue

Write-Host
Write-Host "install luarocks: " -ForegroundColor Yellow
$luarocks_exe = install_luarocks
if (-not $luarocks_exe) { return }
Write-Host $luarocks_exe -ForegroundColor Blue

Write-Host
Write-Host "install libs: " -ForegroundColor Yellow
Write-Host "-------------------------------------------------"

if (-not $conf.libs) {
    Write-Host "no libs installed" -ForegroundColor Blue
}

foreach($lib in $conf.libs.PSObject.Properties)
{
    $name, $ver = $lib.Name, $lib.Value

    if ( $name.StartsWith("rocks") ) { continue }
    if ( $name.StartsWith("#") ) { continue }
    if ( $ver.StartsWith("#") ) { continue }

    install "$name@$ver"

}

Write-Host "-------------------------------------------------"
Write-Host
