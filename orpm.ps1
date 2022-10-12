
$cmd = $args[0]

if ($cmd -eq "start") {
    . $PSScriptRoot\scripts\start.ps1
}elseif ($cmd -eq "stop") {
    . $PSScriptRoot\scripts\stop.ps1
}elseif ($cmd -eq "update") {
    . $PSScriptRoot\scripts\update.ps1
}else{
    Write-Host "-------------------"
    Write-Host "ormp start"
    Write-Host "ormp stop"
    Write-Host "ormp update"
    Write-Host "-------------------"
}
