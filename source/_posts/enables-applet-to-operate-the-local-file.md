---
title: java applet 数字签名  使applet能操作本地文件
tags:
categories:
  - 杂
date: 2010-01-01 17:32:08
---

我做的是一个基于applet的聊天系统。由于IE的安全策略不允许applet有太多的权限。如果涉及到了本地资源，对APPLET一定要进行数字签名和认证。

我开始用的是jdk1.6 ，它的bin文件里命令很不全。于是乎我装了下jdk1.5，命令还是蛮全的。。。。

cmd 到命令行模式：
cd 到 jdk1.5的bin目录下，（我懒得设置系统变量，开始设置没好使，我就不管了，又不是非搞不可……）

命令如下：
1.生成钥匙
keytool -genkey -keystore client.keystore -alias client
生成一个client.keystore的文件。会要求输入一个密码，要记住还要用的。还有一些垃圾问题，问题直接pass掉就好。。。

2.用生成的钥匙为jar文件签名。
jarsigner -keystore client.keystore ChatClient.jar client

其中的jar包如何生成，上一篇已经说过了。。。

3．将公共钥匙导入到一个cer文件中，这个cer文件就是要拷贝到客户端的唯一文件 。

keytool -export -keystore client.keystore -alias client-file client.cer

这样就会生成另外一个 client.cer文件。

拷贝这3个文件到你的web服务器的目录下。。。。加上你原来写好的调用applet的html文件，恩……应该可以运行了。。。。


祝大家开心。。。。

