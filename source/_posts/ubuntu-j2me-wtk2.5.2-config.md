---
title: ubuntu 配置 j2me 环境  wtk2.5.2
tags:
    - ubuntu
    - j2me
    - wtk
categories:
    - linux
date: 2010-01-31 17:50:37
---

PS:已经安装jdk 1.6，eclipse
 
1.下载eclipseme.zip && wtk2.5.2 (java sun 的linux版)
 
2.eclipse -> help ->install new software ******（略)，添加eclipseme.zip。
 
3.wtk2.5.2 安装：
 
环境需求，其实不知道用不用，不过我都sudo apt-get install ** 安装了。
System Requirements - Software
Microsoft Windows XP and Linux-x86 (English version tested with Ubuntu 6.x)
The following libraries should be present on the system running Ubuntu v6.x:
ibXpm (libxpm-dev)
libXt (libxt-dev)
libX11 (libx11-dev)
libICE (libice-dev)
libSM (libsm-dev)
libpthread (libc6-dev)
libm (libc6-dev)
libnsl (libc6-dev)
libstdc++6-dev
JavaTM 2 Platform, Standard Edition (Java SE SDK), version 1.5.0 - if you plan to do development, or JavaTM 2, Standard Edition Runtime Environment (JRE), version 1.5.0 - if you only plan to run the demonstration applications.
To download the SDK or JRE you want, go to http://java.sun.com/javase/downloads/index.html
Apple QuickTime player (required to play AMR media on Windows)
To play Adaptive Multi-Rate (AMR) content on Linux you must have a 3GPP reference implementation. Chapter 8 of the Sun Java Wireless Toolkit User's Guide describes how to enable AMR support.
 
下载的wtk2.5.2 为
 sun_java_wireless_toolkit-2.5.2_01-linuxi486.bin.sh 文件
 
~#sudo chmod +x sun_java_wireless_toolkit-2.5.2_01-linuxi486.bin.sh
~#sudo ./sun_java_wireless_toolkit-2.5.2_01-linuxi486.bin.sh
 
中间过程会让你选择，jdk/bin所在路径 ，还有设置安装路径 。安装路径设置在/home/*目录下，否则安装到最后会提示用户权限不够。
 
4.eclipse 添加 wtk：
eclipse -> windows -> Preferences -> J2ME ->Divce Managerment ,import 你刚才 安装wtk的目录。refresh - 会出现几个 divce,不用考虑，都添加就好了。
 
5.新建一个j2me项目看看。。

