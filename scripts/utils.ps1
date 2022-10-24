
# 获取根目录
function get_root_path() {
    $path = Get-Location
    while($path) {
        if (Test-Path "$path/.orpmrc") {
            return ("$path").replace("`\","`/")
        } else {
            $path = Split-Path $path
        }
    }
}

# 取得 .orpm 目录
function get_orpm_path() {
    $drive = (Get-Location).Drive.Root
    return ($drive + ".orpm").replace("`\","`/")
}

# 获取 orpm 配置
function get_orpm_conf() {

    $root = get_root_path
    if (-not $root) { return }

    Get-Content "$root/.orpmrc" | ConvertFrom-JSON

}

# 取得子目录
function get_child_path($parent, $child) {
    $path = Get-ChildItem -Path $parent -Recurse | Where-Object { $_.Name -eq $child }
    if ($path) {
        return $path.FullName.Replace("`\", "`/")
    }
}

# 取得 lua-resty 目录
function get_resty_path($parent) {
    get_child_path $parent "resty"
}

function get_lua_modules($parent, $bit) {
    $path = get_child_path $parent $bit
    if ($path) {
        get_child_path $path "lua_modules"
    }
}

# 创建目录
function make_path($path) {
    if ( -not (Test-Path $path) ) {
        New-Item -Path $path -ItemType Directory | Out-Null
    }
}

# 创建链接
function make_link($path, $link) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
    }
    New-Item -Path $path -ItemType Junction -Value $link | Out-Null
}

# 下载并解压
function download_expand($Uri, $OutFile, $OutPath, $Force) {

    if (-not (Test-Path $OutFile) -or $Force) {
        try{
            # wget.exe "$Uri" -O "$OutFile"                            # wget下载
            Invoke-WebRequest -Uri $Uri -OutFile $OutFile              # 下载文件
        } catch {
            Write-Host "下载文件失败: " -ForegroundColor Yellow -NoNewline
            Write-Host "$Uri" -ForegroundColor Red
            return
        }
    }

    try{
        7z.exe x "$OutFile" -o"$OutPath" -y -aoa  | Out-Null                  # 7zip解压
    } catch {
        try {
            Expand-Archive -Path $OutFile -DestinationPath $OutPath -Force    # 解压文件
        } catch {
            Write-Host "解压文件失败: " -ForegroundColor Yellow -NoNewline
            Write-Host "$OutFile" -ForegroundColor Red
            return
        }
    }

    return $true

}
