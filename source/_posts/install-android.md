---
title: Android 安装
tags:
categories:
  - 杂
date: 2010-02-03 11:05:54
---

1)解压Android SDK
执行如上目录下的文件：SDK Setup.exe，（机器人图标的哪个）
注意：一般的话会出现 Failed to fetch URL https://dl-ssl.google.com/android/repository/repository.xml，所以应该修改如下几个地方：
a)修改Available Packages,点击"add Site..",增加: http://dl-ssl.google.com/android/repository/repository.xml,当然了，你可以删除原来使用https做连接的site.这个只能更新一些API的package.
b)修改代理配置：Settings里Http Proxy Server:10.159.192.62,Http Proxy Port:8080,选择如下两个选项卡：Force https//.....using http...,还有一个：Ask Before restaring ADB.
c)选择Installed package,里面会有SDK1.1,1.5,1.6,2.0和多个版本的APIs及Usb Driver package.
至此，所有SDK安装完毕。CALL，也不知中国为什么封技术性的网站，按照如上做能够省出你更多的时间来。

2)安装Google为我们提供的Eclipse 开发插件(ADT),地址：https://dl-ssl.google.com/android/eclipse/  
