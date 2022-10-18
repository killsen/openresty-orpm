# 引入工具库
. $PSScriptRoot\utils.ps1

$root = get_root_path

if ($root) {
    Write-Host "已存在配置文件: " -ForegroundColor Yellow -NoNewline
    Write-Host "$root\.orpmrc" -ForegroundColor Blue
    return
}

$path = Get-Location
$file = "$path\.orpmrc"

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
    }
}

set_default "app_name"          ""
set_default "openresty_ver"     ""
set_default "libs"              @{}

$conf | ConvertTo-Json | Set-Content "$file"

Write-Host "创建配置文件: " -ForegroundColor Yellow -NoNewline
Write-Host "$file" -ForegroundColor Blue
