
# 获取根目录
function get_root_path() {
    $path = Get-Location
    while($path) {
        if (Test-Path "$path/.openrestyrc") {
            return "$path"
        } else {
            $path = Split-Path $path
        }
    }
}

# 取得 lib/resty 目录
function get_resty_path($path) {
    $resty = Get-ChildItem -Path $path -Recurse | Where-Object { $_.Name -eq "resty" }
    return $resty.FullName
}

function log($log) {
    Write-Host $log -ForegroundColor Blue
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
