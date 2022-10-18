
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

# 取得 lua-resty 目录
function get_resty_path($path) {
    $resty = Get-ChildItem -Path $path -Recurse | Where-Object { $_.Name -eq "resty" }
    return $resty.FullName
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
function download_expand($url, $file, $path, $remove) {

    if ( -not (Test-Path $file) ) {
        try{
            # wget.exe "$url" -O "$file"                            # wget下载
            Invoke-WebRequest -Uri $url -OutFile $file              # 下载文件
        } catch {
            Write-Host "下载文件失败: " -ForegroundColor Yellow -NoNewline
            Write-Host "$url" -ForegroundColor Red
            return
        }
    }

    if ($remove -and (Test-Path $path)) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction Stop   # 删除目录
    }

    try{
        7z.exe x "$file" -o"$path" -y -aoa  | Out-Null                  # 7zip解压
    } catch {
        try {
            Expand-Archive -Path $file -DestinationPath $path -Force    # 解压文件
        } catch {
            Write-Host "解压文件失败: " -ForegroundColor Yellow -NoNewline
            Write-Host "$file" -ForegroundColor Red
            return
        }
    }

    return $true

}
