#!/bin/sh

# 第一次运行请先创建命令并授权
# echo "sh ~/orpm.sh" > /usr/bin/orpm
# chmod u+x /usr/bin/orpm

app_name="[app_name]"
app_ver="[app_ver]"
app_zip="$app_name-$app_ver.zip"
luarocks_ver="[luarocks_ver]"

mysql_host="127.0.0.1"
mysql_port="3306"
mysql_uid="root"
mysql_psw="12345678"

function show_menu () {

    clear
    cat << EOF

    ################################################################
    项目名称: $app_name v$app_ver
    ################################################################

    s) 启动 openresty           1) 安装 openresty
    r) 重启 openresty           2) 安装 nginx_app
    q) 停止 openresty           3) 安装 luarocks clib
                                4) 安装 mysql

    11) access日志      12) error日志
    21) 访问首页        22) 压力测试

    #### 数据库 ####    30) 数据库连接
    31) 检查表结构      32) 升级表结构

EOF

    read -p "请选择操作: " menu_op
    echo ""
    cd ~

    case $menu_op in

        1) install_openresty        ;;
        2) install_nginx_app        ;;
        3) install_luarocks         ;;
        4) install_mysql            ;;

        11) tail -f ~/nginx/logs/access.log  ;;
        12) tail -f ~/nginx/logs/error.log   ;;

        21) curl "http://127.0.0.1/" ;;
        22) ab -kc 1000 -n 50000 -k "http://127.0.0.1/" ;;

        30) mysql -h$mysql_host -P$mysql_port -u$mysql_uid -p$mysql_psw ;;

        31) curl "http://127.0.0.1/$app_name/initdaos"                        ;;
        32) curl "http://127.0.0.1/$app_name/initdaos?add_column&drop_column" ;;

        s)
            sudo pkill openresty
            sudo openresty -p ~/nginx/ -c ~/nginx/conf/nginx.conf

            sleep 1
            ps -ef | grep openresty
            ;;
        r)
            sudo openresty -p ~/nginx/ -c ~/nginx/conf/nginx.conf -s reload

            sleep 1
            ps -ef | grep openresty
            ;;
        q)
            sudo pkill openresty

            sleep 1
            ps -ef | grep openresty
            ;;

        x)
            exit 0
            ;;

        *)
            show_menu
            ;;
    esac

    echo ""
    read -p "请按回车键继续..."
    show_menu
}

# 测试域名
function test_https (){

    echo "https://$1/"
    echo "-------------------------------------------------------"
    curl -I "https://$1/" --resolve $1:443:127.0.0.1
    echo "-------------------------------------------------------"
    openssl s_client -connect $1:443                            \
                     -status -tlsextdebug < /dev/null 2>&1 |    \
                     grep -i "OCSP response"

}

# CentOS 8 下载安装 openresty ##################################################

# OpenResty® Linux 包
# http://openresty.org/cn/linux-packages.html

function install_openresty () {

    echo ""
    echo "#########################################"
    echo "##### 下载并安装 openresty          #####"
    echo "#########################################"
    echo ""

    sudo yum -y install wget            # 安装 wget  工具库
    sudo yum -y install httpd-tools     # 安装 httpd 工具（如ab）

    # 添加 openresty 仓库
    wget https://openresty.org/package/centos/openresty.repo -O openresty.repo
    sudo mv openresty.repo /etc/yum.repos.d/

    # 更新 yum 索引:
    sudo yum check-update

    # 安装 openresty 及相关工具
    sudo yum -y install openresty
    # sudo yum -y install openresty-resty
    # sudo yum -y install openresty-doc
    # sudo yum -y install openresty-opm

    # 列出 openresty 仓库的软件包
    # sudo yum --disablerepo="*" --enablerepo="openresty" list available
}


function install_luarocks () {

    echo ""
    echo "#########################################"
    echo "##### 下载并安装 luarocks           #####"
    echo "#########################################"
    echo ""

    echo "安装 gcc make 以及其它依赖"
    echo "-----------------------------------------"
    sudo yum -y install gcc make unzip git wget curl lz4-devel
    sudo yum -y install libtermcap-devel ncurses-devel libevent-devel readline-devel
    echo ""

    cd ~
    rocks_tree=~/.rocks
    mkdir $rocks_tree

    echo "下载并安装 luarocks"
    echo "-----------------------------------------"
    wget https://luarocks.github.io/luarocks/releases/luarocks-$luarocks_ver.tar.gz -O luarocks-$luarocks_ver.tar.gz
    tar -zxvf luarocks-$luarocks_ver.tar.gz
    cd luarocks-$luarocks_ver

    # 配置 luajit 路径
    ./configure --lua-suffix=jit \
                --with-lua=/usr/local/openresty/luajit \
                --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
                --rocks-tree=$rocks_tree

    # 构建并安装
    make && make install
    cd ~

    echo ""
    echo "#########################################"
    echo "##### 下载并安装 luarocks clib      #####"
    echo "#########################################"
    echo ""

    echo "安装 luafilesystem"
    echo "https://github.com/lunarmodules/luafilesystem"
    echo "-----------------------------------------"
    luarocks install luafilesystem
    echo ""

    echo "安装 luautf8"
    echo "https://github.com/starwing/luautf8"
    echo "-----------------------------------------"
    luarocks install luautf8
    echo ""

    echo "安装 hashids"
    echo "https://github.com/leihog/hashids.lua"
    echo "-----------------------------------------"
    luarocks install hashids
    echo ""

    echo "安装 lua-iconv"
    echo "https://github.com/ittner/lua-iconv"
    echo "-----------------------------------------"
    luarocks install lua-iconv
    echo ""

    echo "安装 luasocket"
    echo "https://github.com/lunarmodules/luasocket"
    echo "-----------------------------------------"
    luarocks install luasocket
    echo ""

    echo "安装 lua-resty-balancer"
    echo "https://github.com/api7/lua-resty-balancer"
    echo "-----------------------------------------"
    luarocks install lua-resty-balancer
    echo ""

    echo "安装 lua-resty-radixtree"
    echo "https://github.com/api7/lua-resty-radixtree"
    echo "-----------------------------------------"
    luarocks install lua-resty-radixtree
    echo ""

    echo "安装 lua-protobuf"
    echo "https://github.com/starwing/lua-protobuf"
    echo "-----------------------------------------"
    luarocks install lua-protobuf
    echo ""

    echo ""
    echo "拷贝 so 文件到 clib 目录"
    echo "-----------------------------------------"
    echo ""

    \cp -fr $rocks_tree/share/lua/5.1/*             ~/lua_modules/lua/
    \cp -fr $rocks_tree/lib/lua/5.1/*               ~/lua_modules/clib/
    \cp -fr $rocks_tree/lib/lua/5.1/lua-utf8.so     ~/lua_modules/clib/utf8.so

}

function install_mysql () {

    echo ""
    echo "#########################################"
    echo "##### 下载并安装 mysql               #####"
    echo "#########################################"
    echo ""

    # 安装MySQL8.0
    sudo yum -y install @mysql

    # 开启启动
    sudo systemctl enable --now mysqld

    # 要检查MySQL服务器是否正在运行
    # sudo systemctl status mysqld

    # 添加密码及安全设置
    sudo mysql_secure_installation

    # 下载并安装 mysql 客户端
    # sudo yum -y install mysql.x86_64

}

function install_nginx_app () {

    echo ""
    echo "########################################"
    echo "##### 升级安装 nginx app           #####"
    echo "########################################"
    echo ""

    # sudo pkill openresty  # 结束进程
    # rm -rf ~/lua_modules/ # 删除目录
    # rm -rf ~/nginx/       # 删除目录

    sudo yum -y install unzip

    # 解压文件：指定字符集，解决中文文件名乱码问题
    unzip -O CP936 -o ~/$app_zip -d ~/

    # 设置upload目录权限：读r=4, 写w=2, 运行x=1
    # chmod 777 ~/nginx/upload

}

##############################
##### openresty 服务管理 #####
##############################

# openresty 服务管理
# sudo /sbin/service openresty start      # 启动
# sudo /sbin/service openresty restart    # 重启
# sudo /sbin/service openresty stop       # 停止
# sudo /sbin/service openresty status     # 状态

# 启动 openresty
# sudo openresty -p /nginx/

# 访问主页
# curl "http://localhost/"

# 压力测试
# ab -kc 1000 -n 50000 -k "http://localhost/"

# 显示日志：按 Ctrl + C 退出
# tail -f /nginx/logs/error.log

# 查找配置文件路径
# find / -name nginx.conf

# 编辑配置文件
# vi /usr/local/openresty/nginx/conf/nginx.conf

# 按Insert进入编辑模式 按Esc切换查看模式
# 在查看模式下输入 :w 保存文件，输入 :q! 退出

# 显示菜单
show_menu
