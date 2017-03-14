---
title: Ubuntu 添加 Windows 引导
tags:
categories:
  - 杂
date: 2009-05-12 12:39:17
---

其实，就是自己不小心造成的后果。小心的话，应该不会如此的费劲！
我是在windows下 用grub安装，因为以前安过，于是把ubuntu 的盘格掉了。坏事了，开机没了引导，因为引导原来是ubuntu的。于是拿了自己的ubuntu 的系统盘（amd的，以前刻这玩的），安完就又可以引导了。但是不喜欢这个ubuntu的版本，我又给格了。
这次，我借了同学的dos启动盘。因为在网上找到方法，用dos：DOS引导盘引导系统到纯DOS提示符下，执行："fdisk /mbr"即可。这样我就不用再为了引导，而装我那个低版本了。
我试了下，果然管用。这样我就又可以进到windows了。
继续grub安装：我安的是8.10,个人不喜欢9.04。ubuntu的7部，前三部正常。到了第四部，竟然一个盘也看不见，windows下的也看不见。费了半天劲，最后试了下：sudo umount -l /isodevice
好了……然后一步步安装完成。
从启电脑，添加windows的启动项：
```
sudo gedit /boot/grub/meun.lst  在ubuntu 启动的后面添加

title        Windows XP
root        (hd0,0)
makeactive
chainloader    +1
```

一、硬盘下启动Ubuntu 8.10 LiveCD
1、在某个分区根目录新建一个Ubuntu目录。
2、将下载的ubuntu-8.10-desktop-i386.iso复制到该目录下。
3、用winRAR打开ISO，解压缩casper目录下的vmlinuz、initrd.gz文件到Ubuntu目录下。
4、下载grub4dos，将grldr文件、menu.lst文件复制到C盘根目录下。
修改menu.lst文件启动 LiveCD，命令如下：
``` 
 title Ubuntu 8.10 LiveCD
 find --set-root /Ubuntu/vmlinuz
 kernel /Ubuntu/vmlinuz boot=casper iso-scan/filename=/Ubuntu/ubuntu-8.10-desktop-i386.iso quiet splash rw persistent debian-installer/locale=zh_CN.UTF-8 console-setup/layoutcode=cn console-setup/variantcode= --
 initrd /Ubuntu/initrd.gz
 boot
```  
5、打开C盘根目录下的隐藏文件boot.ini，在文件后面加入：C:\GRLDR=ubuntu。
6、重新启动电脑，在启动菜单中选择ubuntu即可。
   
二、安装Ubuntu 8.10
1、进入Ubuntu 8.10 LiveCD后，首先打开“附件\终端”，输入：sudo umount -l /isodevice。可以防止Ubuntu 8.10安装过程无法显示分区。
2、点击桌面的“安装”，开始安装。前三步可以默认。
3、第四步出现分区列表后，选择“手动”。
如果没有事先预留空闲的空间，则选择要安装的分区（至少10G），删除该分区成为“空闲的空间”。
如果已有了预留空闲的空间，则可以选择“空闲的空间”进行分区和安装。
分区的方法很多，我用最简单的：新建1G逻辑分区，类型swap，我的电脑名称为：/dev/sda9；剩下的类型ext3，挂载点“/”，我的电脑名称为/dev/sda10。
选择ext3分区，点击“下一步”。
4、第五步到第六步也是默认。
5、第七步最关键：默认把grub启动加载器安装到MBR，对某些电脑可能造成无法启动，而且重装window时也会被破坏掉。我将其修改的方法是：点击“高级”，在“安装启动加载器的设备”选择挂载点“/”的分区，我的是：/dev/sda10。
注：第七步默认安装造成无法启动电脑情况的，修复方法：用DOS启动盘进入DOS中，运行：fdisk /mbr。重启电脑，就可以进入windows。

三、手动增加Ubuntu 8.10启动项
1、安装结束后，选择继续使用Ubuntu 8.10 LiveCD。
2、进入C盘，将menu.lst该名。并确保其他分区根目录下没有menu.lst文件。
3、进入Ubuntu 8.10安装的“/”分区（我的电脑是/dev/sda10），复制boot文件夹到C盘根目录下。
4、重启电脑，选择ubuntu后，grldr文件后自动找到C盘boot/grub文件夹下的menu.lst文件。选择第一个启动Ubuntu 8.10。

四、重装windows系统的恢复。
1、重装windows系统前备份C盘根目录下的boot文件夹、grldr文件、boot.ini文件。重装后再复制到C盘。
2、如果没有备份，则将附件的grldr文件复制到C盘，打开C盘根目录下的隐藏文件boot.ini，在文件后面加入：C:\GRLDR=ubuntu。并将Ubuntu 8.10安装的“/”分区下的boot文件夹复制到C盘根目录下。


