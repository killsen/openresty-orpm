param(
    [String] $ver
)

$ver = $ver.ToLower()

if (-not $ver -or $ver -eq "master" -or $ver -eq "last") {
    $ver = "main"
}

if ($ver -eq "main") {
    $ZIP_FILE = "https://github.com/killsen/openresty-orpm/archive/refs/heads/main.zip"
} else {
    $ZIP_FILE = "https://github.com/killsen/openresty-orpm/archive/refs/tags/v$ver.zip"
}

$ORPM_PATH = "$env:USERPROFILE\.orpm\orpm"
$ARCH_PATH = "$ORPM_PATH\openresty-orpm-$ver"
$ARCH_FILE = "$ORPM_PATH\openresty-orpm-$ver.zip"
$CURR_PATH = "$ORPM_PATH\current"

Write-Host
Write-Host "Welcome To Install ORPM"
Write-Host

if ( -not (Test-Path $ORPM_PATH) ) {
    New-Item -Path $ORPM_PATH -ItemType Directory | Out-Null
}

if (Test-Path $ARCH_PATH) {
    Remove-Item -Path $ARCH_PATH -Recurse -Force -ErrorAction Stop
}

Write-Host "Download File: " -ForegroundColor Yellow -NoNewline
Write-Host $ZIP_FILE -ForegroundColor Blue

try{
    Invoke-WebRequest -Uri $ZIP_FILE -OutFile $ARCH_FILE
} catch {
    Write-Host "Download File Fail" -ForegroundColor Red
    Write-Host
    return
}

Write-Host "Unzip File: " -ForegroundColor Yellow -NoNewline
Write-Host $ARCH_FILE -ForegroundColor Blue

try {
    Expand-Archive -Path $ARCH_FILE -DestinationPath $ORPM_PATH -Force
} catch {
    Write-Host "Unzip File Fail" -ForegroundColor Red
    Write-Host
    return
}

if (-not (Test-Path $ARCH_PATH)) {
    Write-Host "Path Not Found: " -ForegroundColor Yellow -NoNewline
    Write-Host "$ARCH_PATH" -ForegroundColor Red
    Write-Host
    return
}

if (Test-Path $CURR_PATH) {
    Remove-Item -Path $CURR_PATH -Recurse -Force -ErrorAction Stop
}

New-Item -Path $CURR_PATH -ItemType Directory | Out-Null

Copy-Item -Path $ARCH_PATH/* -Destination $CURR_PATH -Recurse -Force

$ENV_PATH = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($ENV_PATH -notmatch [Regex]::Escape($CURR_PATH)) {
    $ENV:PATH = "$CURR_PATH;$ENV_PATH"
    [System.Environment]::SetEnvironmentVariable("PATH", $ENV:PATH, "User")

    Write-Host "Add Path To Environment: " -ForegroundColor Yellow -NoNewline
    Write-Host "$CURR_PATH" -ForegroundColor Blue
}

Write-Host "ORPM Installed: " -ForegroundColor Yellow -NoNewline
Write-Host "$CURR_PATH" -ForegroundColor Blue

. $CURR_PATH\orpm.ps1
