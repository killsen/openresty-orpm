# 文件编码: UTF-8 with BOM

Write-Host
Write-Host "stop process nginx*" -ForegroundColor Blue
Write-Host

# 关闭 nginx 进程
Get-Process -Name "nginx*" | Stop-Process -PassThru
