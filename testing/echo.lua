
ngx.header["content-type"] = "text/plain"

local function echo(...)
    ngx.say(...)
    ngx.flush()
end

echo "Welcome OpenResty!"
echo "-----------------------"

for i=1, 5 do
    echo(i, ") ", ngx.localtime())
    ngx.sleep(1)
end

echo "-----------------------"
echo "ByeBye OpenResty!"
