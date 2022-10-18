# 引入工具库
. $PSScriptRoot\utils.ps1
. $PSScriptRoot\install_openresty.ps1
. $PSScriptRoot\install_mingw.ps1
. $PSScriptRoot\install_luarocks.ps1
. $PSScriptRoot\install.ps1

$root = get_root_path

if ($root) {
    Write-Host "root: $root" -ForegroundColor Red
} else {
    Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
    return
}

try {
    $conf = Get-Content "$root/.orpmrc" | ConvertFrom-JSON
} catch {
    Write-Host ".orpmrc 文件读取失败" -ForegroundColor Red
    return
}

if (-not $conf.libs) {
    log "no lua resty libs installed"
    return
}

# 关闭 nginx 进程
Get-Process -Name "nginx*" | Stop-Process -PassThru

Write-Host
Write-Host "install openresty"
$openresty_win32 = install_openresty
if (-not $openresty_win32) { return }
$openresty_win32

Write-Host
Write-Host "install mingw"
$mingw32_bin = install_mingw
if (-not $mingw32_bin) { return }
$mingw32_bin

Write-Host "install luarocks"
$luarocks_exe = install_luarocks
if (-not $luarocks_exe) { return }
$luarocks_exe

Write-Host
Write-Host "install libs"

foreach($lib in $conf.libs.PSObject.Properties)
{
    if (-not ($lib.Value.StartsWith("#")) ) {
        $lib_ver = $lib.Name + "@" + $lib.Value
        install $lib_ver
    }
}
