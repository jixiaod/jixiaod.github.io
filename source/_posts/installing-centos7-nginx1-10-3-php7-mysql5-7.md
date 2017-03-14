---
title: CentOS 7 从零开始搭建 LNMP 环境（nginx/1.10.3 PHP/7.1.2 Mysql/5.7.17）
date: 2017-03-03 10:10:36
tags:
    - linux
    - nginx
    - PHP
    - mysql
categories:
    - linux
---

最近买了 Linode VPS 服务。5刀每月，只有1G的内存，编译 Mysql 内存溢出，然后升级到2G内存的版本，每月10刀……以下纪录 LNMP 环境安装过程：

## 安装 Nginx

```sh
~# yum install wget
~# wget http://nginx.org/download/nginx-1.10.3.tar.gz
~# tar zxf nginx-1.10.3.tar.gz
~# cd nginx-1.10.3

~# yum install pcre-devel pcre openssl openssl-devel
~# yum install gcc
~# ./configure --prefix=/opt/nginx
~# make & make install
```

修改配置文件，启动 Nginx服务
```sh
~# /opt/nginx/sbin/nginx
```

重启
```sh
~# /opt/nginx/sbin/nginx -s reload
```


## 安装 PHP

```sh
~# wget http://jp2.php.net/get/php-7.1.2.tar.gz/from/this/mirror
~# tar zxf mirror
~# cd php-7.1.2
```

```sh
~# yum install zlib-devel zlib libxml2 libxml2-devel  libpng libpng-devel libcurl-devel curl libcurl libzip-devel libzip gd bzip2-devel bzip2

~# ./configure --prefix=/opt/php  --enable-fpm --with-openssl  --with-zlib  --with-mysqli=mysqlnd  --enable-pcntl --enable-soap --enable-zip --enable-sockets --enable-mbstring  --with-curl --with-pcre-regex  --with-bz2 --with-gd  --with-pdo-mysql=mysqlnd  --with-mysqli=mysqlnd   --enable-maintainer-zts

~# make & make install
```

启动 php-fpm，使用默认的配置文件
```sh
~# cd /opt/php
~# mv etc/php-fpm.conf.default etc/php-fpm.conf
~# mv etc/php-fpm.d/www.conf.default etc/php-fpm.d/www.conf
~# sbin/php-fpm -y etc/php-fpm.conf
```


## 安装 Mysql

```sh
~# wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.17.tar.gz
~# tar zxf mysql-5.7.17.tar.gz
~# cd mysql-5.7.17

// cmake安装mysql，会自行下载并安装boost

~# yum install  cmake gcc gcc-c++ ncurses-devel cmake libaio  bison

~# cmake . -DCMAKE_INSTALL_PREFIX=/opt/mysql -DWITH_BOOST=/opt/boost/ -DMYSQL_DATADIR=/opt/mysql/data -DWITH_INNOBASE_STORAGE_ENGINE=1 -DMYSQL_UNIX_ADDR==/opt/mysql/mysql.sock -DMYSQL_USER=mysql -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci

~# make & make install
```

创建 Mysql 账户
```sh
~# groupadd mysql
~# useradd -r -g mysql -s /bin/false mysql
~# chown -R mysql .
~# chgrp -R mysql .
```

启动 Mysql 服务

```sh
//生成初始化 Mysql 帐号root 密码
[root@li1571-79 mysql]# bin/mysqld --initialize --user=mysql
2017-03-03T02:59:23.230496Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2017-03-03T02:59:23.576085Z 0 [Warning] InnoDB: New log files created, LSN=45790
2017-03-03T02:59:23.628088Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
2017-03-03T02:59:23.685971Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: 67ce62cb-ffbd-11e6-a9b9-f23c91e57db2.
2017-03-03T02:59:23.688763Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
2017-03-03T02:59:23.690301Z 1 [Note] A temporary password is generated for root@localhost: &H4FpSyD/b6<
```

最后的 `&H4FpSyD/b6<` 即是生成的临时账户，启动 Mysql 服务
```sh
~# cp support-files/mysql.server /opt/mysql/bin
~# cd /opt/mysql
~# bin/mysql.server start 
```
```sh
[root@li1571-79 mysql]# bin/mysql -uroot -p -h127.0.0.1 -P3306
Enter password:
输入临时帐号密码，即可进入mysql 客户端。第一次登录，强制需要修改临时密码
```
```mysql
mysql> alter user 'root'@'localhost' identified by '123abc';
Query OK, 0 rows affected (0.01 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.01 sec)

```

到这里，LNMP 到这里LNMP 初始默认环境搭建完成。



