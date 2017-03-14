---
title: ubuntu8.10安装jdk-6u10-linux-i586.bin
tags:
    - Java
    - ubuntu
categories:
    - Java
date: 2009-04-19 20:37:58
---

1、sun网站上下载jdk-6u10-linux-i586.bin；
2、一般默认下载到桌面；
3、比如安装到/usr/java目录下；
4、使用命令建立目录：sudo mkdir -v /sur/java；
5、拷贝下载的jdk-6u10-linux-i586.bin到以上建立的目录中：sudo cp -v /home/micheal/桌面/jdk-6u10- linux-i586.bin /usr/java；
6、进入安装目录：cd /usr/java；
7、赋予权限：sudo chmod u+x jdk-6u10-linux-i586.bin;
8、执行安装：sudo ./jdk-6u10-linux-i586.bin;
9、配置环境变量：
``` 
export JAVA_HOME=/usr/java/jdk1.6.0_10
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin
```
10、测试是否成功：
```
~$ java -version
java version "1.6.0_10"
Java(TM) SE Runtime Environment (build 1.6.0_10-b33)
Java HotSpot(TM) Client VM (build 11.0-b15, mixed mode, sharing)
```
见到这个信息就是你安装成功了！


