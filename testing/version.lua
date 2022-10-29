
local ffi = require "ffi"

ngx.header["content-type"] = "text/plain"

ngx.say ""
ngx.say "Welcome OpenResty!"
ngx.say (ngx.localtime())
ngx.say "------------------------------------------"
ngx.say (ffi.os, " ", ffi.arch)
ngx.say ""

local function load_lib(lib_name)
    local pok, lib = pcall(require, lib_name)
    if pok then
        ngx.say(lib_name, ": ", lib._VERSION or lib.VERSION or " (ok)")
    else
        ngx.say(lib_name, ": ", lib)
    end
end

load_lib("lfs")
load_lib("socket")
load_lib("utf8")
load_lib("hashids")
load_lib("iconv")

ngx.say ""
ngx.say "------------------------------------------"
ngx.say ""

load_lib("resty.mlcache")
load_lib("resty.template")
load_lib("resty.http")
load_lib("resty.iputils")

ngx.say ""
ngx.say "------------------------------------------"
ngx.say ""

ffi.cdef[[
const char *zlibVersion();
const char *OpenSSL_version(int t);
const char *ngx_http_lua_ffi_pcre_version(void);
]]

local zlibVersion = ffi.string(ffi.C.zlibVersion())
ngx.say("zlibVersion: ", zlibVersion)

local OpenSSL_version = ffi.string(ffi.C.OpenSSL_version(0))
ngx.say("OpenSSL_version: ", OpenSSL_version)

local pcre_version = ffi.string(ffi.C.ngx_http_lua_ffi_pcre_version())
ngx.say("pcre_version: ", pcre_version)
