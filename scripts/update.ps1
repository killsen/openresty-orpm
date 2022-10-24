# 引入工具库
. $PSScriptRoot\utils.ps1
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
Get-Process -Name "nginx*" | Stop-Process -PassThru

Write-Host
Write-Host "update libs: " -ForegroundColor Yellow
Write-Host "-------------------------------------------------"

if (-not $conf.libs) {
    Write-Host "no libs installed" -ForegroundColor Blue
}

function update_lib_ver($lib, $ver) {
    Write-Host "$lib@$ver" -ForegroundColor Yellow -NoNewline

    if ($ver -eq "main" -or $ver -eq "master") {
        Write-Host " >> " -ForegroundColor Red -NoNewline
        install "$lib@$ver"
        return
    }

    try {
        $url   = "https://github.com/$lib/tags"
        $regx  = "archive/refs/tags/(v?[\d.]+)\.zip"
        $links = (Invoke-WebRequest -Uri "$url").Links | Where-Object { $_.href -match "$regx" }

        if ($links[0].href -match "$regx") {
            if ($ver -eq $Matches[1]) {
                Write-Host " (版本一致) " -ForegroundColor Blue
            } else {
                $ver = $Matches[1]
                Write-Host " >> " -ForegroundColor Red -NoNewline
                install "$lib@$ver"
            }
            return
        }
    } catch {}

    Write-Host " (获取版本失败) " -ForegroundColor Red -NoNewline
    Write-Host "$url"
}

foreach($lib in $conf.libs.PSObject.Properties)
{
    $name, $ver = $lib.Name, $lib.Value

    if ( $name.StartsWith("rocks") ) { continue }
    if ( $name.StartsWith("#") ) { continue }
    if ( $ver.StartsWith("#") ) { continue }

    update_lib_ver $name $ver

}

Write-Host "-------------------------------------------------"
Write-Host
