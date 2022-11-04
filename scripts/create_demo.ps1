
for ($x=1; $x -lt 100; $x=$x+1) {
    if (-not (Test-Path "orpm-demo-$x")) {
        $demo = "orpm-demo-$x"
        break
    }
}

if (-not $demo) {
    return
}

orpm create $demo
Set-Location $demo

git init
git add .
git commit -m "init repo" | Out-Null

orpm install

git add .
git commit -m "init libs" | Out-Null

code .
code .\nginx\testing\echo.lua

orpm start
