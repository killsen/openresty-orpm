﻿
$version  = "v1.0.5"
$homepage = "https://github.com/killsen/openresty-orpm"

function add_line($p1, $p2) {
    if (-not $p1) {
        Write-Host "---------------------------------------------------------"
    } else {
        Write-Host "orpm " -ForegroundColor Yellow -NoNewline
        Write-Host "$p1 "  -ForegroundColor Blue   -NoNewline
        Write-Host "$p2 "
    }
}

function show_menu() {

    Clear-Host

    add_line "version" " # 版本 $version"
    add_line "homepage" "# $homepage"

    add_line
    add_line "init" "    # 创建 .openrestyrc 配置文件"
    add_line "start" "   # 启动 nginx 服务"
    add_line "stop" "    # 停止 nginx 服务"
    add_line "update" "  # 升级 lua-resty-libs"
    add_line "install" " # 安装 lua-resty-lib"
    add_line
    add_line "install" " bungle/lua-resty-template@v2.0"
    add_line "install" " ledgetech/lua-resty-http@v0.16.1"
    add_line "install" " thibaultcha/lua-resty-mlcache@2.5.0"
    add_line

}

switch ($args[0]) {
    "version" { add_line "version" "$version"       }
    "homepage"{ Start-Process -FilePath "$homepage" }

    "init"    { . $PSScriptRoot\scripts\init.ps1    }
    "start"   { . $PSScriptRoot\scripts\start.ps1   }
    "stop"    { . $PSScriptRoot\scripts\stop.ps1    }
    "update"  { . $PSScriptRoot\scripts\update.ps1  }

    "install" {
        if (-not $args[1]) {
            show_menu
        } else {
            . $PSScriptRoot\scripts\install.ps1
            install $args[1]
        }
    }

    default {   show_menu }
}