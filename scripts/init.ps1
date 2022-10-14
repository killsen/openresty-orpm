

$path = Get-Location
$file = "$path\.openrestyrc"

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
set_default "lua_resty_libs"    @{}

$conf | ConvertTo-Json | Set-Content "$file"

Write-Host "创建配置文件: " -ForegroundColor Yellow -NoNewline
Write-Host "$file" -ForegroundColor Blue
