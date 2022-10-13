
$path = Get-Location
$file = "$path\.openrestyrc"

if (-not (Test-Path $file)) {
    New-Item $file -ItemType File | Out-Null
}

try {
    $conf = Get-Content "$file" | ConvertFrom-JSON
} catch {

}

if (-not $conf) {
    $conf = @{}
}

if (-not $conf.app_name) {
    $conf | Add-Member "app_name" "" -Force
}

if (-not $conf.openresty_ver) {
    $conf | Add-Member "openresty_ver" "" -Force
}

if (-not $conf.lua_resty_libs) {
    $conf | Add-Member "lua_resty_libs" @() -Force
}

$conf | ConvertTo-Json | Set-Content "$file"

Write-Host "配置文件已创建: " -ForegroundColor Yellow -NoNewline
Write-Host "$file" -ForegroundColor Blue
