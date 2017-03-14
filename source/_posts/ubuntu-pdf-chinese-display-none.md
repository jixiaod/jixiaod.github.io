---
title: Ubuntu Pdf 中文不显示解决办法
tags:
categories:
  - 杂
date: 2009-11-08 22:57:06
---

今天下了本ebook，结果打开了。里面除了一张封皮，其他的页面一片空白。网上搜了解决办法，网上poppler-data版本是0.1，去官网下载已经是3.0版本。



1.sudo apt-get install  xpdf-chinese-simplified   

2.下载安装poppler-data-0.1者过程如下：
下载poppler-data-0.3.0.tar.gz (官网 http://poppler.freedesktop.org/ )
解压放置到/opt文件夹下面。
~$:sudo cp '/home/tiger/poppler-data-0.3.0.tar.gz' /opt
~$:cd /opt
~$:sudo tar zxvf poppler-data-0.3.0.tar.gz
~$:cd poppler-data-0.3.0


安装：
~$:sudo make install datadir=/usr/share
 
可以了，中文乱码问题部分解决了，

