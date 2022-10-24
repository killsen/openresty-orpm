# 引入工具库
. $PSScriptRoot\utils.ps1
. $PSScriptRoot\install_openresty.ps1
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

# 关闭 nginx 进程
Get-Process -Name "nginx*" | Stop-Process

$openresty = install_openresty
if (-not $openresty) { return }

$luarocks_exe = install_luarocks
if (-not $luarocks_exe) { return }

$nginx = "$root/nginx"
make_path $nginx
make_path $nginx/conf
make_path $nginx/temp
make_path $nginx/logs

if (-not (Test-Path "$nginx/conf/nginx.conf")) {
    $conf = Get-Content "$PSScriptRoot/../template/nginx.conf"
    Set-Content "$nginx/conf/nginx.conf" $conf
}

$nginx_exe = "$openresty/nginx.exe"

Write-Host ---------------------------------------------
& $nginx_exe -v
Write-Host ---------------------------------------------

Write-Host http://127.0.0.1/ -ForegroundColor Blue

$app_name = $conf.app_name
if ($app_name) {
    Write-Host http://127.0.0.1/$app_name/help  -ForegroundColor Blue
    Write-Host http://127.0.0.1/$app_name/_.gen_api_code.lpage -ForegroundColor Blue
}

Write-Host ---------------------------------------------
Write-Host "path: $root/nginx" -ForegroundColor Red
Write-Host "conf: $root/nginx/conf/nginx.conf" -ForegroundColor Red
Write-Host

# 运行 nginx
Start-Process $nginx_exe -ArgumentList "-p $root/nginx" -NoNewWindow
