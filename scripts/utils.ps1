
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

# 取得包的配置信息
function get_lib_conf($path) {

    $file = get_child_file $path ".orpmrc"
    if ($file) {
        Get-Content $file | ConvertFrom-JSON
    }

}

# 初始化 .rocks 目录
function init_rocks_path() {

    $root = get_root_path
    $conf = get_orpm_conf

    if (-not $root) { return }

    make_path "$root/lua_modules"
    # make_path "$root/lua_modules/resty"

    # make_path "$root/lua_types"
    # make_path "$root/lua_types/luajit"
    # make_path "$root/lua_types/lualib"
    # make_path "$root/lua_types/ngx"
    # make_path "$root/lua_types/resty"

    make_path "$root/.rocks/32bit"
    # make_path "$root/.rocks/32bit/bin"
    make_path "$root/.rocks/32bit/lua_modules"
    make_path "$root/.rocks/32bit/lua_modules/clib"
    make_path "$root/.rocks/32bit/lua_modules/lua"

    make_path "$root/.rocks/64bit"
    # make_path "$root/.rocks/64bit/bin"
    make_path "$root/.rocks/64bit/lua_modules"
    make_path "$root/.rocks/64bit/lua_modules/clib"
    make_path "$root/.rocks/64bit/lua_modules/lua"

    if ($conf.arch -eq "64bit" -or $conf.arch -eq "64") {
        make_link "$root/lua_modules/clib" "$root/.rocks/64bit/lua_modules/clib"
        make_link "$root/lua_modules/lua"  "$root/.rocks/64bit/lua_modules/lua"
    } else {
        make_link "$root/lua_modules/clib" "$root/.rocks/32bit/lua_modules/clib"
        make_link "$root/lua_modules/lua"  "$root/.rocks/32bit/lua_modules/lua"
    }

}

# 查找文件
function get_child_file($parent, $name) {

    $item = Get-ChildItem -Path $parent -File | Where-Object { $_.Name -eq $name }
    if ($item) {
        $file = $item.FullName.Replace("`\", "`/")
        return $file
    }

    foreach ($item in (Get-ChildItem -Path $parent -Directory)) {
        $file = get_child_file $item.FullName $name
        if ($file) {
            return $file
        }
    }
}

# 取得子目录
function get_child_path($parent, $name) {

    $item = Get-ChildItem -Path $parent -Directory | Where-Object { $_.Name -eq $name }
    if ($item) {
        $path = $item.FullName.Replace("`\", "`/")
        return $path
    }

    foreach ($item in (Get-ChildItem -Path $parent -Directory)) {
        $path = get_child_path $item.FullName $name
        if ($path) {
            return $path
        }
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
