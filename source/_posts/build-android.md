---
title: Building Android
tags:
categories:
  - 杂
date: 2009-04-15 15:51:10
---

## 1.Environment Requirement
Linux 2.6 (Ubuntu /Debian is recommended)
确保安装了以下的东西：
gcc autoconf automake git-core gnupg flex bison gperf libsdl-dev libesd0-dev libwxgtk2.6-dev build-essential zip curl python jdk valgrind

## 2.Installing repo Script
Installation
mkdir ~/bin
export PATH=$PATH:~/bin
curl http://android.git.kernel.org/repo >~/bin/repo
chmod a+x ~/bin/repo
Configuring
repo init -u git://android.git.kernel.org/platform/manifest.git

## 3.Download & build
repo sync
Make
export ANDROID_PRODUCT_OUT=./out/target/product/generic
export PATH=${PATH}:./out/host/linux-x86/bin
emulator


## 最后，可以设置一个脚本 让他不用那么麻烦启动

sudo vi ~/.bashrc

打开vim后，把下面俩句添加到最后

export ANDROID_PRODUCT_OUT=/home/tiger/out/target/product/generic
export PATH=${PATH}:/home/tiger/out/host/linux-x86/bin

保存退出，另开一个终端：

emulator

结果一样的！

