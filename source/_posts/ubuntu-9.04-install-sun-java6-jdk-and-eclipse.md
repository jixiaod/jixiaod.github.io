---
title: ubuntu 9.04安装配置 sun-java6-jdk 和 eclipse
tags:
    - Java
    - ubuntu
    - JDK
    - eclipse
categories:
  - Java
date: 2009-09-12 18:29:54
---

安装eclipse
sudo apt-get install sun-java6-jdk

配置jdk    sudo update-alternatives －－config java   选择 配置  jdk6(/usr/lib/jvm/java-6-openjdk/jre/bin/java)


配置path 和java_home

sudo gedit /etc/environment     添加如下两句

配置PATH和JAVA_HOME

CLASSPATH=/usr/lib/jvm/java-6-sun/lib
JAVA_HOME=/usr/lib/jvm/java-6-sun

安装eclipse
sudo apt-get install eclipse

将java-6-sun设置为系统默认
sudo update-java-alternatives -s java-6-sun

配置jvm，此jvm为自己建立的文件
sudo gedit /etc/jvm
在里面加入
/usr/lib/jvm/java-6-sun

sudo gedit /etc/eclipse/java_home
在最上方添加
/usr/lib/jvm/java-6-sun

此时配置已经生效，可以使用eclipse写java了。。。

