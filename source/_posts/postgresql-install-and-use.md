---
title: PostgreSQl 安装和使用
date: 2016-08-01 14:44:48
tags:
    - postgresql
categories:
    - 数据库

---

## 安装

1.使用 Yum 安装 

```
~$ sudo yum install postgresql-server postgresql
```

2.编译安装 

下载最新的源码包 https://www.postgresql.org/ftp/source/

```
~$ sudo yum install readline-devel
~$ ./configure --prefix=/opt/postgresql
~$ make && make install
```

初始化数据库配置 

```
~$ /opt/postgresql/bin/initdb -D /opt/pgdata/
```

启动数据库 

```
~$ /opt/postgresql/bin/pg_ctl start -D /opt/pgdata/
```

PostgreSQL 默认建立的帐户既是当前的系统账户，并且建立了一个名为postgres的数据库。尝试登陆 

```
[lan_dev@v194 ~]$ /opt/postgresql/bin/psql -h127.0.0.1 -p5432 -Ulan_dev -dpostgres
psql (9.5.3)
Type "help" for help.

postgres=# 
```

psql 常用命令 

```
\h：查看SQL命令的解释，比如\h select。 
\?：查看psql命令列表。 
\l：列出所有数据库。 
\c [database_name]：连接其他数据库。 
\d：列出当前数据库的所有表格。 
\d [table_name]：列出某一张表格的结构。 
\du：列出所有用户。 
\e：打开文本编辑器。 
\conninfo：列出当前数据库和连接的信息。 
```

建立新的帐户 

```
postgres=# CREATE USER konguser WITH PASSWORD '123456';
CREATE ROLE
```

创建数据库 

```
postgres=# CREATE DATABASE kong OWNER kong;
CREATE DATABASE
```

赋予所有 kong 数据库的权限给帐户 konguser，否则 konguser 就只能登陆控制台，没有任何数据库操作权限 

```
postgres=# GRANT ALL PRIVILEGES ON DATABASE kong to konguser;
GRANT
```


## 配置远程登录 

1.查看Postgresql 的配置文件，打开 pg_hba.conf 文件，能看到如下的纪录： 

```
~$ vim /opt/pgdata/pg_hba.conf 
# "local" is for Unix domain socket connections only 
local all all trust 
# IPv4 local connections: 
host all all 127.0.0.1/32 trust 
# IPv6 local connections: 
host all all ::1/128 
```
能看出默认的 Postgresql 配置只允许 loacalhost（127.0.0.1） 的访问。添加纪录 

```
host all all 192.168.20.1/24 trust 
```

配置文件中每个配置项代表什么内容都写的很详细。如果不知道配置文件路径，可在psql客户端查看 

```
[jigang@v5 postgresql]$ bin/psql -U jigang -d postgres -h 127.0.0.1 -p 5432
psql (9.5.3)
Type "help" for help.
postgres=# show config_file;
config_file
----------------------------------------
/opt/postgresql/dbdata/postgresql.conf
(1 row)
 ```


2.修改 postgresql.conf 文件，修改 listen_addresses 配置为 '*' 

```
listen_addresses = 'localhost'  # what IP address(es) to listen on; 
                                # comma-separated list of addresses; 
                                # defaults to 'localhost'; use '*' for all 
                                # (change requires restart) 
```
从新启动PostgreSQL 

```
~$ /opt/postgresql/bin/pg_ctl restart -D /opt/pgdata/
```

3.打开防火墙 

```
~$ sudo iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
```

4.测试远程登录数据库 

```
tiger➜work/moji/code» psql -h192.168.1.194 -p5432 -dkong -Ukonguser [17:48:12]
Password for user konguser:
psql (9.5.3)
Type "help" for help.
kong=>
```

后记

PostgreSQL 的 SQL 跟 Mysql 几乎完全一样。

