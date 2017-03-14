---
title: ubuntu 配置 eclipse 启动图标
tags:
categories:
  - 杂
date: 2010-02-07 14:47:15
---

安装eclipse之前，请先确定你安装了jdk。

1、首先下载eclipse-SDK，这是目前最新版本的eclipse 。解压到＊＊目录下。

2.在/usr/bin目录下创建一个启动脚本eclipse，执行下面的命令来创建：

创建：

sudo gedit /usr/bin/eclipse

然后在该文件中添加以下内容：

```
#!/bin/sh
export MOZILLA_FIVE_HOME="/usr/lib/mozilla/"
export ECLIPSE_HOME="/home/tiger/eclipse"
```
$ECLIPSE_HOME/eclipse $*


3.让修改该脚本的权限，让它变成可执行，执行下面的命令：

sudo chmod +x /usr/bin/eclipse
我做到此处为止，可以通过终端运行
～＃eclipse
来运行啦。

4.在桌面或者gnome菜单中添加eclipse启动图标
（1）在桌面或者启动面板上添加图标：
在桌面（右键单击桌面->创建启动器）或面板（右键单击面板->添加到面板 ->定制应用程序启动器）上创建一个新的启动器，然后添加下列数据：
名称：Eclipse Platform
命令：eclipse
图标： /home/tiger/eclipse/icon.xpm

（2）在Applications（应用程序）菜单上添加一个图标
用文本编辑器在/usr/share/applications目录里新建一个名为eclipse.desktop的启动器，如下面的命令:

sudo vi /usr/share/applications/eclipse.desktop
或者
sudo gedit /usr/share/applications/eclipse.desktop

然后在文件中添加下列内容：

[Desktop Entry]
Encoding=UTF-8
Name=Eclipse Platform
Comment=Eclipse IDE
Exec=eclipse
Icon=/home/tiger/eclipse/icon.xpm
Terminal=false
StartupNotify=true
Type=Application
Categories=Application;Development;

保存文件。完成整个安装过程。可以双击桌面eclipse的图标来运行eclipse


