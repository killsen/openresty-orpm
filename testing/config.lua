
ngx.header["content-type"] = "text/plain"

ngx.say ""
ngx.say "Welcome OpenResty! "
ngx.say (ngx.localtime())
ngx.say "------------------------------------------"
ngx.say ""

ngx.say ( "ngx.config.subsystem          ", ngx.config.subsystem       )
ngx.say ( "ngx.config.debug              ", ngx.config.debug           )
ngx.say ( "ngx.config.prefix()           ", ngx.config.prefix()        )
ngx.say ( "ngx.config.nginx_version      ", ngx.config.nginx_version   )
ngx.say ( "ngx.config.ngx_lua_version    ", ngx.config.ngx_lua_version )

ngx.say ""
ngx.say "------------------------------------------"
ngx.say ""

local conf = ngx.config.nginx_configure()
conf = string.gsub(conf, "--prefix", "\n--prefix")
conf = string.gsub(conf, "--with-", "\n--with-")
conf = string.gsub(conf, "--add-", "\n--add-")
ngx.say ( "ngx.config.nginx_configure()")
ngx.say ( conf )
ngx.say ""
