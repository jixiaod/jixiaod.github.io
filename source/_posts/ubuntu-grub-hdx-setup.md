---
title: Ubuntu 引导盘设置
tags:
categories:
  - 杂
date: 2009-10-19 19:59:17
---

最近手痒，在尝试移动硬盘启动计算机，由于它使用的也是GRUB启动的方式，导致我本机的GRUB产生了error 17 错误！

解决方法：

看了网上高手对这个问题的解释，基本是出在MBR上，决定重装GRUB到硬盘第一个分区的MBR

使用Ubuntu Live CD启动后，打开终端命令行

sudo grub

find   /boot/grub/stage1 #find命令会返回一个值，比如我这是(hd0,5)

root  (hdx,x) #如果find命令返回的(hd0,5)，这里你就root  (hd0,5)

setup  (hdx) #如果find命令返回的是(hd0,num)，你就 setup  (hd0)

如果提示ok、成功后，重启系统，看到久违的GRUB启动界面。

