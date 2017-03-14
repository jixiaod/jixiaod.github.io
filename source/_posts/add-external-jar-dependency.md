---
title: 添加外部 Jar 包依赖
tags:
categories:
  - 杂
date: 2010-01-03 22:47:20
---

对于一些java应用程序，引用了jre以外的jar包，则需要把外部jar打到jar包中。。。

1.可以在MANIFEST.MF的Class-Path中定义。。

MANIFEST.MF的文件：

Manifest-Version: 1.0
Main-Class: com.test
Class-Path: looks.jar forms.jar syntax.jar jgraph.jar foxtrot.jar osworkflow-2.8.0.jar oscore-2.2.5.jar


2.用eclipse的fat-jar插件

这个很方便，我就是这么做的。。。

