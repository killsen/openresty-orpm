# 引入工具库
. $PSScriptRoot\utils.ps1
. $PSScriptRoot\install.ps1

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

if (-not $conf.lua_resty_libs) {
    log "no lua resty libs installed"
    return
}

# 关闭 nginx 进程
Get-Process -Name "nginx*" | Stop-Process -PassThru

foreach($lib in $conf.lua_resty_libs.PSObject.Properties)
{
    if (-not ($lib.Value.StartsWith("#")) ) {
        $lib_ver = $lib.Name + "@" + $lib.Value
        install $lib_ver
    }
}
