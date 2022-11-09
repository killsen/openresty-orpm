# OpenResty ORPM

A Very Simple [OpenResty](https://openresty.org) Package Manager

## 通过 PowerShell 直接安装 orpm

Open a PowerShell terminal (version 5.1 or later) and run:

```PowerShell

# Optional: Needed to run a remote script the first time
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

irm https://raw.githubusercontent.com/killsen/openresty-orpm/main/scripts/install_orpm.ps1 | iex

```

## 通过 [scoop](https://scoop.sh/) 安装 orpm

```PowerShell

# 添加 dev 仓库
scoop bucket add dev https://github.com/killsen/scoop-dev

# 更新 scoop
scoop update

# 通过 scoop 安装 orpm
scoop install dev/orpm

```

## orpm 常用命令

```PowerShell

orpm version  # 版本 v2.4.3
orpm homepage # https://github.com/killsen/openresty-orpm

orpm demo     # 创建演示项目
orpm create   # 创建项目
orpm init     # 创建 .orpmrc 配置文件
orpm start    # 启动 nginx 服务
orpm stop     # 停止 nginx 服务
orpm build    # 打包 nginx app

orpm update   # 升级 orpm
orpm install  # 安装 libs
orpm rocks    # 执行 luarocks

```

## 安装 libs

```PowerShell
orpm install  killsen/openresty-clib
orpm install  killsen/openresty-appx
orpm install  killsen/openresty-lua-types

orpm install  bungle/lua-resty-template       # 安装最新版本
orpm install  bungle/lua-resty-template@v2.0  # 安装指定版本
```
