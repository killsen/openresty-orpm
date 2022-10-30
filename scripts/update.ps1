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

$libs = $conf.libs

if (-not $libs) {
    Write-Host "no libs installed" -ForegroundColor Blue
}

# 清空已安装列表
$Global:INSTLLED = @{}

foreach($item in $libs.PSObject.Properties)
{
    $author_lib, $ver = $item.Name, $item.Value
    $pattern = "([\w-]+)/([\w-]+)"

    if (-not ($author_lib -match $pattern)) { continue }
    $author, $lib = $Matches[1], $Matches[2]

    if ( $author -eq "rocks" ) { continue }
    if ($ver.IndexOf("#") -ne -1 ) { continue }

    if ($ver -eq "main" -or $ver -eq "master") {
        install "$author_lib@$ver"
    } else {
        install "$author_lib@$last"
    }

}

# 清空已安装列表
$Global:INSTLLED = @{}

Write-Host "-------------------------------------------------"
Write-Host
