# 引入工具库
. $PSScriptRoot\utils.ps1
. $PSScriptRoot\install_openresty.ps1

# 清屏
Clear-Host

# 关闭 nginx 进程
Get-Process -Name "nginx*" | Stop-Process

$root = get_root_path

if ($root) {
    Write-Host "root: $root" -ForegroundColor Red
} else {
    Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
    return
}

try {
    $conf = Get-Content "$root/.orpmrc" | ConvertFrom-JSON
    if (-not $conf) { $conf = @{} }
} catch {
    Write-Host ".orpmrc 文件读取失败" -ForegroundColor Red
    return
}

$openresty = install_openresty
if (-not $openresty) { return }

$nginx_exe = "$openresty/nginx.exe"

Write-Host ---------------------------------------------
& $nginx_exe -v
Write-Host ---------------------------------------------

$app_name = $conf.app_name
if ($app_name) {
    Write-Host http://127.0.0.1/$app_name/help  -ForegroundColor Blue
    Write-Host http://127.0.0.1/$app_name/_.gen_api_code.lpage -ForegroundColor Blue
} else {
    Write-Host http://127.0.0.1/ -ForegroundColor Blue
}
Write-Host ---------------------------------------------
Write-Host "path: $root\nginx" -ForegroundColor Red
Write-Host "conf: $root\nginx\conf\nginx.conf" -ForegroundColor Red

# 关闭 nginx 进程
Get-Process -Name "nginx*" | Stop-Process -PassThru

# 运行 nginx
Start-Process $nginx_exe -ArgumentList "-p $root\nginx" -NoNewWindow
