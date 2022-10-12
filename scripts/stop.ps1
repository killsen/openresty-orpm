# 文件编码: UTF-8 with BOM

# 清屏
Clear-Host

Write-Host "stop process nginx*" -ForegroundColor Blue

# 关闭 nginx 进程
Get-Process -Name "nginx*" | Stop-Process -PassThru
