# 引入工具库
. $PSScriptRoot\utils.ps1

function add_log($msg, $info) {
    Write-Host $msg -ForegroundColor Yellow -NoNewline
    Write-Host $info -ForegroundColor Blue
    Write-Host
}

function create_app($app_name, $temp_name) {

    if (-not $app_name) {
        add_log "应用名称不能为空"
        return
    }

    if (-not ($app_name -match "^\w[\w-]*$")) {
        add_log "应用名称不合法: "  $app_name
        return
    }

    $path = (Get-Location).ToString().Replace("`\", "`/")
    $path+= "/$app_name"

    if (Test-Path $path) {
        add_log "目录已经存在: " $path
        return
    }

    if (-not $temp_name) {
        $temp_name = "default"
    }

    $temp = "$PSScriptRoot/../template/$temp_name"
    if (-not (Test-Path $temp)) {
        add_log "模板不存在: " $temp_name
        return
    }

    New-Item -Path $path -ItemType Directory | Out-Null

    Copy-Item -Path $temp/* -Destination $path -Recurse

    add_log "应用已创建: " $path

}
