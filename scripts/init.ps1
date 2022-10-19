# 引入工具库
. $PSScriptRoot\utils.ps1

$root = get_root_path
$path = (Get-Location).ToString().Replace("`\", "`/")
$file = "$path/.orpmrc"

if ($root -and $root -ne $path) {
    Write-Host
    Write-Host "配置文件已存在: " -ForegroundColor Yellow
    Write-Host "$root/.orpmrc" -ForegroundColor Blue
    Write-Host
    return
}

if (-not (Test-Path $file)) {
    New-Item $file -ItemType File | Out-Null
}

$conf = Get-Content "$file" | ConvertFrom-JSON
if (-not $conf) { $conf = @{} }

# 设置默认值
function set_default($key, $default) {
    $type = $default.GetType().Name
    if ($type -eq "Hashtable") { $type = "PSCustomObject" }
    if ($null -eq  $conf.($key) -or $type -ne $conf.($key).GetType().Name) {
        $conf | Add-Member "$key" $default -Force
    } elseif ("" -eq $conf.($key) -and "String" -eq $type) {
        $conf.($key) = $default
    }
}

set_default "app_name"          ""
set_default "openresty_ver"     "1.21.4.1"
set_default "luarocks_ver"      "3.9.1"
set_default "mingw_ver"         "12.2.0"
set_default "arch"              "32bit"
set_default "libs"              @{}

$conf | ConvertTo-Json | Set-Content "$file"

Write-Host
Write-Host "配置文件已创建: " -ForegroundColor Yellow
Write-Host "$file" -ForegroundColor Blue
Write-Host
