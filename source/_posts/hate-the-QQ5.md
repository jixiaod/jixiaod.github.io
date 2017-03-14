---
title: 讨厌的QQ5
tags:
categories:
  - 杂
date: 2009-01-04 18:04:12
---

今天发现QQ5设为主页实在是太烦了！于是想换掉，结果还挺麻烦。

1.我先改的注册表。进到注册表里，然后搜索“QQ5”。有一个结果，在Inernet Explorer—》Main—》Start Page。恩……是QQ5，改掉。原以为就好了，没想到还挺顽固。打开IE还那样，再想办法吧。

2.又在网上搜到个结果，只要改注册表
HKEY_CLASSES_ROOT\CLSID\{871C5380-42A0-1069-A2EA-08002B30309D}\shell\OpenHomePage\Command就可以了，可以看到数据值"C:\Program Files\Internet Explorer\IEXPLORE.EXE" http://www.qq5.com   (原因找到了)

3.最后又发现，桌面的IE没问题了。但是快速启动栏的IE还是QQ5。你把快速启动栏的IE拖到桌面，看看他的属性。明白了吧……呵呵

