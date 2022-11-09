# 引入工具库
. $PSScriptRoot\utils.ps1

$root = get_root_path
$conf = get_orpm_conf

Write-Host

if (-not $root) {
    Write-Host ".orpmrc 文件不存在" -ForegroundColor Red
    Write-Host
    return
}

$site  = "$root/site"
$temp  = "$site/temp"
$nginx = "$site/nginx"
$zip   = "$site/nginx.zip"

if (Test-Path $temp) {
    Remove-Item -Path $temp -Recurse -Force -ErrorAction Stop
}

make_path   $site
make_path   $temp
make_path   $nginx

make_path   $temp/lua_modules
make_path   $temp/lua_modules/app
make_path   $temp/lua_modules/resty
make_path   $temp/lua_modules/clib
make_path   $temp/lua_modules/lua

make_path   $temp/nginx
make_path   $temp/nginx/app
make_path   $temp/nginx/conf
make_path   $temp/nginx/html
make_path   $temp/nginx/logs
make_path   $temp/nginx/temp

Copy-Item   $root/lua_modules/app/*     $temp/lua_modules/app/   -Force -Recurse
Copy-Item   $root/lua_modules/resty/*   $temp/lua_modules/resty/ -Force -Recurse

Copy-Item   $root/nginx/app/*           $temp/nginx/app/   -Force -Recurse
Copy-Item   $root/nginx/conf/*          $temp/nginx/conf/  -Force -Recurse
Copy-Item   $root/nginx/html/*          $temp/nginx/html/  -Force -Recurse
Copy-Item   $root/nginx/*.lua           $temp/nginx/       -Force

Copy-Item   $nginx/*                    $temp/nginx/       -Force -Recurse

Copy-Item   $PSScriptRoot/../orpm.sh    $site/             -Force -Recurse

Compress-Archive -Path $temp/* -DestinationPath $zip  -Force

Start-Process $site
