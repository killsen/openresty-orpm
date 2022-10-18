﻿# 引入工具库
. $PSScriptRoot\utils.ps1
. $PSScriptRoot\install_openresty.ps1
. $PSScriptRoot\install_mingw.ps1
. $PSScriptRoot\install_luarocks.ps1
. $PSScriptRoot\install.ps1

$root = get_root_path
$orpm = get_orpm_path

Clear-Host
Write-Host

if ($root) {
    Write-Host "workspace: $root" -ForegroundColor Red
    Write-Host "orpm home: $orpm" -ForegroundColor Red
} else {
    Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
    Write-Host
    return
}

try {
    $conf = Get-Content "$root/.orpmrc" | ConvertFrom-JSON
} catch {
    Write-Host ".orpmrc 文件读取失败" -ForegroundColor Red
    Write-Host
    return
}

# 关闭 nginx 进程
Get-Process -Name "nginx*" | Stop-Process -PassThru

Write-Host
Write-Host "install openresty" -ForegroundColor Yellow
$openresty_win32 = install_openresty
if (-not $openresty_win32) { return }
Write-Host $openresty_win32 -ForegroundColor Blue

Write-Host
Write-Host "install mingw" -ForegroundColor Yellow
$mingw32_bin = install_mingw
if (-not $mingw32_bin) { return }
Write-Host $mingw32_bin -ForegroundColor Blue

Write-Host
Write-Host "install luarocks" -ForegroundColor Yellow
$luarocks_exe = install_luarocks
if (-not $luarocks_exe) { return }
Write-Host $luarocks_exe -ForegroundColor Blue

Write-Host
Write-Host "install libs" -ForegroundColor Yellow
Write-Host "-------------------------------------------------"

if (-not $conf.libs) {
    Write-Host "no libs installed" -ForegroundColor Blue
}

foreach($lib in $conf.libs.PSObject.Properties)
{
    if (-not ($lib.Value.StartsWith("#")) ) {
        $lib_ver = $lib.Name + "@" + $lib.Value
        install $lib_ver
    }
}

Write-Host "-------------------------------------------------"
Write-Host
