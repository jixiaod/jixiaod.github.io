---
title: Eclipse + Tomcat5.5 + Apache-ant-1.7.1 （J2EE）环境配置
tags:
    - Java
    - eclipse
    - tomcat
    - apache
    - ant
categories:
    - Java
date: 2009-05-18 22:37:23
---

## 1.环境变量设置：
安装eclipse ,tomcat,和ant,然后设置环境变量：
我的电脑->高级->环境变量->用户变量

ANT_HOME     C:\apache\apache-ant-1.7.1
CATALINA_HOME    C:\apache\Tomcat-5.5.27
ECLIPSE_HOME    C:\eclipse
JAVA_HOME    C:\java\jdk1.6.0_11
PATH         %JAVA_HOME%\bin;
                  %ANT_HOME%\bin;

## 2.启动eclipse
windows ->preferences ->server->Runtime Environments
选择Tomcat v5.5 Server

ant ->runtime
选择自己安装的apache-ant-1.7.1

## 3.创建自己的项目
运行eclipse   新建 java application  导入sample文件为项目的源文件
根据自己情况修改build.xml修改
然后ant 运行 ，开启tomcat服务。打开浏览器（IE），http://localhost:8080/sample/  就可以自己的页面
