---
title: Ubuntu Java3D 环境配置
tags:
categories:
  - 杂
date: 2009-10-22 00:15:57
---

事先安装jdk 1.6版本，eclipse 3.2。

到java sun  官网下载sun 开发的3d jar包。这个包是单独的，没有包含在jdk中。到下面网站下载最新jar包。

http://java.sun.com/javase/technologies/desktop/java3d/
推荐下面这个网站，各种开发可能学要的jar包，很全。

http://s.pudn.com/search_hot_en.asp?k=java+3D

将3Djar 包添加到eclipse的classpath 的libraries 。

从网上下了一个网球的3D游戏http://www.redbrick.dcu.ie/~acathla/index.html

这个网球游戏还需要一个另外的一个包java3dgamesdk.jar。可从
https://java3dgamesdk.dev.java.net/servlets/ProjectDocumentList;jsessionid=83BC8B86E0165123EEDAC85509FA5450
得到。

需要注意的是：如果程序不能运行，提示
Exception in thread "main" java.lang.UnsatisfiedLinkError: no j3dcore-ogl in java.library.path
解决方法如下：
java3d 的安装目录中还有个  i386 文件夹。里面俩个.so文件。需要添加到classpath中，如下 晕啊（没法加图片）

添加到j3dcore.jar - /usr/local/java3d/lib/ext展开，把i386目录添加到Native library location:处。

这样程序应该能运行了。

