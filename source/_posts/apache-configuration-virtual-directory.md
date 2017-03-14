---
title: Apache 配置虚拟目录
tags:
categories:
  - 杂
date: 2010-08-05 12:23:12
---

为了更方便调试代码，（需要同时做2个以上网站的时候）修改虚拟目录可以更方便。


确定能打开页面后，打开文件“apache2.2/conf/httpd.conf”。找到如下内容

```
<Directory />
    Options FollowSymLinks
    AllowOverride None
    Order deny,allow
    Deny from all
</Directory>
```

以上这段代码设置了，浏览器访问的 参数。看他的目录为"/"即Apache默认的路径浏览器方可访问，如果你的网站目录不在此的话，那么你先得在以下代码的下面 一样写葫芦将你的网站目录设置为可访问。如下：

```
<Directory "d:/www">    //欲设置的虚拟目录路径
    AllowOverride None
    Options None
    Order allow,deny
    Allow from all
</Directory>
```

这样我就把我放的网站的文件目录设置完毕了。

以下开始添加虚拟目录：
在httpd.conf文件的最后，插入代码

```
NameVirtualHost *:80
<VirtualHost *:80>
     ServerAdmin super_tiger@yahoo.cn    
     DocumentRoot "d:/www"           
     ServerName www.test.com    
     ErrorLog  logs/www.tzwan.com-error_log             
     CustomLog  logs/www.tzwan.com-access_log common      
</VirtualHost>
```

这样就算是设置www.test.com这 个网站的虚拟主机完成，重启一下HTTPD服务。
你可以在本地机器找到并打开C:\WINDOWS\system32\drivers\etc\hosts这个文件 添加如下一行

127.0.0.1  www.test.com

然后呢，你在本地浏览器中输入以下域名即可运行。



