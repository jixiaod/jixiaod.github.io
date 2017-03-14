---
title: CentOS 6.6 安装 mysql 5.7
tags:
  - mysql
categories:
  - Linux
date: 2016-10-14 12:05:45
---
在 CentOS 的 yum 默认安装的是 mysql 5.5 版本，由于开发需要 5.6 以上版本，索性就装个 5.7。

到官网下载对应的 rpm buddle 包，CentOS 6 选择选择如下对应的版本

>*Red Hat Enterprise Linux 6 / Oracle Linux 6 (x86, 64-bit), RPM Bundle    5.7.15    440.2M*
>*(mysql-5.7.15-1.el6.x86_64.rpm-bundle.tar)*

安装前，如果已经安装了 Mysql 5.5， 需要卸载旧版的 Mysql。

```shell
[root@v194 ~]# rpm -qa |grep mysql
mysql-libs-5.1.73-7.el6.x86_64
mysql-community-libs-5.6.33-2.el6.x86_64
mysql-5.1.73-7.el6.x86_64
mysql-community-server-5.6.28-2.el6.x86_64

[root@v194 ~]# rpm -e --nodeps mysql-libs-5.1.73-7.el6.x86_64
[root@v194 ~]# rpm -e --nodeps mysql-community-libs-5.6.33-2.el6.x86_64 mysql-5.1.73-7.el6.x86_64 mysql-community-server-5.6.28-2.el6.x86_64
```

删除旧的Mysql目录，不删会有问题。

```
[root@v194 ~]# ls  -l  /var/lib|grep mysql
drwxr-xr-x  5 mysql    mysql    4096 11月 17 2015 mysql
[root@v194 ~]# rm -rf /var/lib/mysql
```

解压安装下载的 bundle 包。

```
~# tar xf mysql-5.7.15-1.el6.x86_64.rpm-bundle.tar
~# cd mysql-5.7.15-1
```

**按照common->libs->client->server 的顺序安装**。

[root@v194 ~]# rpm -ivh mysql-community-common-5.7.15-1.el6.x86_64.rpm
[root@v194 ~]# rpm -ivh mysql-community-libs-5.7.15-1.el6.x86_64.rpm
[root@v194 ~]# rpm -ivh mysql-community-client-5.7.15-1.el6.x86_64.rpm
[root@v194 ~]# rpm -ivh mysql-community-server-5.7.15-1.el6.x86_64.rpm

启动 mysqld

```
[root@v194 ~]# service mysqld start
```

找到临时登录密码

Mysql 5.7 的密码不在是默认为空，而是在安装的log中。查找文件内容中的临时密码，密码为 yQO64H%Khrts

```
[root@v194 ~]# vim /var/log/mysqld.log
……
2016-10-11T07:03:47.910712Z 1 [Note] A temporary password is generated for root@localhost: yQO64H%Khrts
……
```

登录 Mysql 客户端
[root@v194 ~]# /usr/bin/mysql -uroot -pyQO64H%Khrts -h127.0.0.1 -P3306

Mysql 5.7 必须要修改root 密码，**并且 root 密码必须包含大写字母、数字和特殊字符**。

```mysql
mysql> alter user 'root'@'localhost' identified by '123abc!@#testABC';
Query OK, 0 rows affected (0.00 sec)
```
…………


