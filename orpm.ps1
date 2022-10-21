﻿
$version  = "v2.2.3"
$homepage = "https://github.com/killsen/openresty-orpm"

function add_line($p1, $p2) {
    if (-not $p1) {
        Write-Host "------------------------------------------------------------"
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
    add_line "init" "    # 创建 .orpmrc 配置文件"
    add_line "start" "   # 启动 nginx 服务"
    add_line "stop" "    # 停止 nginx 服务"
    add_line "update" "  # 升级 libs"
    add_line "install" " # 安装 libs"
    add_line "rocks" "   # 执行 luarocks"
    add_line
    add_line "install" " bungle/lua-resty-template       # 安装最新版本"
    add_line "install" " bungle/lua-resty-template@v2.0  # 安装指定版本"
    add_line "install" " ledgetech/lua-resty-http"
    add_line "install" " thibaultcha/lua-resty-mlcache"
    add_line "install" " killsen/openresty-clib@v1.0.0"
    add_line "install" " rocks/luafilesystem"
    add_line

}

switch ($args[0]) {
    "version" { add_line "version" "$version"       }
    "homepage"{ Start-Process -FilePath "$homepage" }

    "init"    { . $PSScriptRoot\scripts\init.ps1    }
    "start"   { . $PSScriptRoot\scripts\start.ps1   }
    "stop"    { . $PSScriptRoot\scripts\stop.ps1    }
    "update"  { . $PSScriptRoot\scripts\update.ps1  }

    "rocks"   {
        . $PSScriptRoot\scripts\install_luarocks.ps1
        $rocks = install_luarocks
        if (-not $rocks) { return }
        if ($args.Count -gt 1) {
            $argx = $args[1..($args.Count-1)]
        }
        & $rocks $argx
    }

    "install" {
        if (-not $args[1]) {
            . $PSScriptRoot\scripts\install_all.ps1
        } else {
            . $PSScriptRoot\scripts\install.ps1
            install $args[1]
        }
    }

    "create" {
        . $PSScriptRoot\scripts\create.ps1
        create_app $args[1] $args[2]
    }

    "hash" {

        try {
            $url  = "https://github.com/killsen/openresty-orpm/archive/refs/tags/$version.zip"
            $file = "$PSScriptRoot/$version.zip"

            Invoke-WebRequest -Uri $url -OutFile $file
            $hash = Get-FileHash -Path $file -Algorithm SHA256
            Remove-Item $file

            Write-Host
            Write-Host "ver  : " -ForegroundColor Yellow -NoNewline
            Write-Host "$version"  -ForegroundColor Blue
            Write-Host "hash : " -ForegroundColor Yellow -NoNewline
            Write-Host $hash.Hash.ToLower()  -ForegroundColor Blue
            Write-Host "json : " -ForegroundColor Yellow -NoNewline
            Write-Host "https://github.com/killsen/scoop-dev/edit/main/bucket/orpm.json"
            Write-Host
        } catch {
            Write-Host
            Write-Host "出错了: " -ForegroundColor Yellow -NoNewline
            Write-Host "$_" -ForegroundColor Red
            Write-Host
        }

    }

    default { show_menu }
}
