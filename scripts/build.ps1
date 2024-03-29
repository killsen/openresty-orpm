﻿# 引入工具库
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

$app_name       = $conf.app_name
$app_ver        = $conf.version
$app_zip        = "$app_name-$app_ver.zip"
$luarocks_ver   = $conf.luarocks_ver

if (Test-Path $root/nginx/conf/nginx-prod.conf) {
    Copy-Item $root/nginx/conf/nginx-prod.conf $temp/nginx/conf/nginx.conf -Force
    Remove-Item $temp/nginx/conf/nginx-prod.conf -Force -ErrorAction Stop
}

if (Test-Path $root/nginx/app/$app_name-prod.lua) {
    Copy-Item $root/nginx/app/$app_name-prod.lua $temp/nginx/app/$app_name.lua -Force
    Remove-Item $temp/nginx/app/$app_name-prod.lua -Force -ErrorAction Stop
}

$shell = Get-Content $PSScriptRoot/../orpm.sh -Encoding UTF8 -Raw

$shell = $shell.Replace("[app_name]"     , $app_name     )
$shell = $shell.Replace("[app_ver]"      , $app_ver      )
$shell = $shell.Replace("[luarocks_ver]" , $luarocks_ver )

Set-Content $site/orpm.sh $shell -Encoding UTF8 -Force

Compress-Archive -Path $temp/* -DestinationPath $site/$app_zip  -Force

Start-Process $site

Write-Host "打包完成: " -ForegroundColor Yellow -NoNewline
Write-Host $app_zip -ForegroundColor Blue
Write-Host
