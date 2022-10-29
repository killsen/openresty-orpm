
ngx.header["content-type"] = "text/plain"

ngx.say ""
ngx.say "Welcome OpenResty!"
ngx.say (ngx.localtime())
ngx.say "------------------------------------------"
ngx.say ""

ngx.say "package.path: "
ngx.say ""
local path = string.gsub(package.path, ";", ";\n")
ngx.say (path)
ngx.say "------------------------------------------"
ngx.say ""
ngx.say "package.cpath: "
ngx.say ""
local cpath = string.gsub(package.cpath, ";", ";\n")
ngx.say (cpath)
