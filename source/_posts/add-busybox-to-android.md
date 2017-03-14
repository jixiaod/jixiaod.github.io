---
title: Android 中添加 Busybox
tags:
    - linux
    - android
    - busybox
categories:
  - linux
date: 2009-04-26 17:06:08
---

## Busybox 在 Android 中的安装

注：我的 anroid 安装目录为  /opt/android  

ramdisk的制作
与linux内核一样，ramdisk.img 也是cpio压缩。需要gunzip解压缩，然后用cpio解包。

将android  /opt/android/out/target/product/generic中的的ramdisk.img文件复制一份到其他目录（不要把原来的弄坏了，我自己开始就弄得乱七八糟的，幸亏能从同学电脑靠分文件回来，要不要从新make android，那可爽了……）。
将ramdisk.img改名ramdisk.img.gz.
解压

~$ gunzip ramdisk.img.gz ramdisk.img   // 又变成.img 文件
 
新建一个文件夹ramdisk,进入ramdisk
~$ cpio -i -F ../ramdisk.img     //  解压文件到ramdisk中
 
在ramdisk中找到init.rc文件，并修改init.rc文件 在PATH后加上busybox的路径，这个是busybox 将要在android的虚拟机中的安装路径
``` 
~$setup the global environment
    export PATH /data/busybox:/sbin:/system/sbin:/system/bin:/system/xbin
    export LD_LIBRARY_PATH /system/lib
    export ANDROID_BOOTLOGO 1
    export ANDROID_ROOT /system
    export ANDROID_ASSETS /system/app
    export ANDROID_DATA /data
    export EXTERNAL_STORAGE /sdcard
    export HOME /   //注意这个别忘了
    export BOOTCLASSPATH /system/framework/core.jar:/system/framework/ext.jar:/system/framework/framework.jar:/system/framework/android.policy.jar:/system/framework/services.jar
```
 
重新打包成镜像文件
```
#cpio -i -t -F ../ramdisk.img > list  //执行后你会发现生成了一个list 文件
#cpio -o -H newc -O rd_ramdisk.img < list  //打包生产新的镜像rd_ramdisk.img
将这个镜像文件复制到 原来的目录下，使用新的镜像启动emulator 
#emulator -noskin -ramdisk rd_ramdisk.img
```

在android中安装busybox

```
//重新打开个终端
#adb shell mkdir /data/busybox   //在虚拟机中建立文件夹busybox
#adb push ../busybox /data/busybox  //写自己的busybox 所在的目录
#adb shell  //进入android
#cd /data/busybox  
#chmod +x busybox 
#busybox   //应该能看到busybox的信息，否则就是哪一步有问题，好好看看。
```
 

## 写个自己的busybox 命令 ，并放到busybox中
//我的busybox 版本 busybox-1.5.2  安装目录/usr/local/tool/busybox-1.5.2
写个自己的小程序hello.c  这个文件放到 /usr/local/tool/busybox-1.5.2/miscutils目录下，在这里编译到busybox中

```
#include "busybox.h"
int hello_main(int argc, char **argv);
int hello_main(int argc, char **argv)
{
    printf("hello tiger\n");
    return 0;
}
```
修改一些文件
1>在/usr/local/tool/busybox-1.5.2/miscutils  找到 Config.in文件，在里面添加（位置放在最后吧）

```
config HELLO
    bool "hello"
    default y    //这里yes ,在menuconfig时就不用选了
    help
      The hello applet will print the config file with which
      busybox was built.
```

2>也是在miscutils 中找到Kbuild文件，添加（安字母顺序添加）

lib-$(CONFIG_HELLO)       += hello.o               //将要添加的命令来源

3>到/usr/local/tool/busybox-1.5.2/include文件夹找到  applets.h

USE_HELLO(APPLET(hello, _BB_DIR_BIN, _BB_SUID_NEVER)) //安字母顺序
这定义了命令名（hello），它在 Busybox 源代码中的函数名（hello_main），应该在哪里会为这个新命令创建链接（在这种情况中，它在 /bin 目录中），最后这个命令是否有权设置用户 id（在本例中是 no）

4>也是在include 文件夹中，usage.h文件（我添加到最后了）

```
#define hello_trivial_usage \
       ""
#define hello_full_usage \
       "Print the config file which built busybox"
```

3.交叉工具链编译busybox

```
~$ make menuconfig  
```

配置内核，在Miscellaneous Utilities 注意看看自己的命令是不是在，并且被够选

```
~$make
```

之后生成busybox ，在这个目录下/usr/local/tool/busybox-1.5.2 。当然还生成了其他的文件，我们只要这个。




