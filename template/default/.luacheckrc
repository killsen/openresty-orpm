
-- luacheck
-- https://github.com/mpeterv/luacheck

-- luacheck 配置文件
-- https://luacheck.readthedocs.io/en/stable/config.html

-- OpenResty 最佳实践: 代码静态分析
-- https://moonbingbing.gitbooks.io/openresty-best-practices/content/test/static_analysis.html

cache = true
std = 'ngx_lua'

-- 错误提醒列表 List of warnings
-- https://luacheck.readthedocs.io/en/stable/warnings.html

ignore = {
    'ok', 'err', 'res', 'self',
    '_',    -- 忽略 _ 变量，我们用它来表示没有用到的变量
    '6..',  -- 忽略格式上的warning
    '541',  -- An empty do end block
    '542',  -- An empty if branch
}

-- 全局变量
globals = {
    'ngx', 'ndk', '_load',
    'io.openx', 'openx', 'dofilex'
}

-- 不检查来自第三方的代码库
exclude_files = {
    '.luacheckrc',  -- 不检查 luacheck 配置文件
    'nginx/api',    -- 不检查 .api.lua 接口文件
    'nginx/resty',
    'nginx/lua',
    'nginx/lualib',
    'lua_modules',
    '.rocks',
}
