﻿# 引入工具库
. $PSScriptRoot\utils.ps1

# 清屏
Clear-Host

# 关闭 nginx 进程
Get-Process -Name "nginx*" | Stop-Process

$root = get_root_path

if ($root) {
    Write-Host "root: $root" -ForegroundColor Red
} else {
    Write-Host ".openrestyrc 文件不存在" -ForegroundColor Red
    return
}

try {
    $conf = Get-Content "$root/.openrestyrc" | ConvertFrom-JSON
} catch {
    Write-Host ".openrestyrc 文件读取失败" -ForegroundColor Red
    return
}

$app_name           = $conf.app_name
$openresty_ver      = $conf.openresty_ver
$nginx              = "$root/nginx"
$openresty          = "$root/.openresty"
$openresty_win32    = "openresty-$openresty_ver-win32"
$nginx_exe          = "$root/.openresty/$openresty_win32/nginx.exe"
$lualib_link        = "$root/.openresty/$openresty_win32/lualib"
$luajit_link        = "$root/.openresty/$openresty_win32/lua/jit"

make_path $openresty

if ( -not (Test-Path $nginx_exe) ) {
    $url  = "https://openresty.org/download/$openresty_win32.zip"
    $file = "$openresty/$openresty_win32.zip"

    try {
        wget.exe "$url" -O "$file"                                      # wget下载
    } catch {
        Invoke-WebRequest -Uri $url -OutFile $file                      # 下载文件
    }

    try {
        7z.exe x "$file" -o"$openresty" -y -aoa  | Out-Null              # 7zip解压
    } catch {
        Expand-Archive -Path $file -DestinationPath $openresty -Force    # 解压文件
    }
}

make_path $nginx
make_path $nginx/temp
make_path $nginx/logs
make_link $nginx/lualib  $lualib_link
make_link $nginx/lua/jit $luajit_link

Write-Host ---------------------------------------------
& $nginx_exe -v
Write-Host ---------------------------------------------
Write-Host http://127.0.0.1/$app_name/help  -ForegroundColor Blue
Write-Host http://127.0.0.1/$app_name/_.gen_api_code.lpage -ForegroundColor Blue
Write-Host ---------------------------------------------

# 运行 nginx
Start-Process $nginx_exe -ArgumentList "-p $nginx" -NoNewWindow
