---
title: 打 Jar 包
tags:
categories:
  - 杂
date: 2010-01-01 09:11:26
---

这段时间太忙，应该把自己学到的东西总结一下。以备不时之需，也可公大家参考。。

让大家少走点弯路……

用eclipse 的工具很方便的生成的jar包 。

右键项目Export ->java->jar file生成jar包。关于MANIFEST.MF文件也可以导入自己写的，也可以通过eclipse来自动生成。

对于有main函数的程序，通过Main class来设置jar包的程序入口，设置好main class 的jar包可以直接运行。

////////////////

Manifest-Version: 1.0
Main-Class: com.izforge.izpack.installer.Installer
Class-Path:

////////////////

Manifest-Version:1.0 版本号
Main-Class 包含main函数的class文件。。注意不要写文件的扩展名 .class ，而且文件夹用 . 来分隔。
Class-Path 是引用的jar包

如果是applet程序没有main函数直接打包就可以。在html中引用的时候，同样按照.class文件所在写出路径，比如：
<applet code=”src/client/applet.class” archive=”MyApplet.jar”>

这样在你的MyApplet.jar 中，打开的结构src/client/appet.class 能够找到applet.class。
对于applet的功能如果涉及到文件读写。就要对jar包“数字签名”或“数字证书”，因为IE对applet的安全策略不允许applet对本地文件的操作。关于数字签名，下篇在写。


因为资料都在公司那里，一会去公司在发出来。。。今天还有个同学过来湾，哎呀。。。晚上又要喝多了。。。

喝多也要吐啊。。
