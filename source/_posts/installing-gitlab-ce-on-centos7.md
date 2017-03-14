---
title: Centos7 安装 Gitlab-CE
date: 2017-03-03 11:30:02
tags:
    - gitlab

---

1. 安装配置依赖项
如想使用Postfix来发送邮件,在安装期间请选择'Internet Site'. 您也可以用sendmai或者 配置SMTP服务 并 使用SMTP发送邮件.
在 Centos 6 和 7 系统上, 下面的命令将在系统防火墙里面开放HTTP和SSH端口.

```
sudo yum install curl policycoreutils openssh-server openssh-clients
sudo systemctl enable sshd
sudo systemctl start sshd
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
sudo firewall-cmd --permanent --add-service=http
sudo systemctl reload firewalld
```

如果提示防火墙没打开，执行
```
systemctl start firewalld
```

2. 添加GitLab仓库,并安装到服务器上
curl -sS http://packages.gitlab.cc/install/gitlab-ce/script.rpm.sh | sudo bash
sudo yum install gitlab-ce


3. 启动GitLab
```
sudo gitlab-ctl reconfigure
```

4. 使用浏览器访问GitLab

首次访问GitLab,系统会让你重新设置管理员的密码,设置成功后会返回登录界面.
默认的管理员账号是root,如果你想更改默认管理员账号,请输入上面设置的新密码登录系统后修改帐号

5.配置域名访问
以上基本是官方内容，以下配置自己的域名。首先添加 godaddy的域名 A 记录到服务器IP。

在文件
```
vi /etc/gitlab/gitlab.rb
```
找到nginx的配置文件位置，并修改默认域名为自己的域名。

更多可官方安装文档 ：https://www.gitlab.cc/downloads/#centos7
