# openresty-orpm

OpenResty Package Management

## 安装 orpm

```PowerShell

# 添加 dev 仓库
scoop bucket add dev https://github.com/killsen/scoop-dev

# 通过 scoop 安装 orpm
scoop install dev/orpm

```

## orpm 常用命令

```PowerShell

orpm version  # 版本 v2.0.1
orpm homepage # https://github.com/killsen/openresty-orpm

orpm init     # 创建 .orpmrc 配置文件
orpm start    # 启动 nginx 服务
orpm stop     # 停止 nginx 服务

orpm update   # 升级 libs
orpm install  # 安装 libs

```

## 安装 libs

```PowerShell

orpm install  bungle/lua-resty-template       # 安装最新版本
orpm install  bungle/lua-resty-template@v2.0  # 安装指定版本

orpm install  ledgetech/lua-resty-http
orpm install  thibaultcha/lua-resty-mlcache

orpm install  rocks/luafilesystem

```
