---
title: ubuntu 关机命令
tags:
    - ubuntu
    - shutdown
categories:
    - linux
date: 2009-12-02 21:58:35
---

关机命令 shutdown
1)shutdown --help
可以查看shutdown命令如何使用，当然也可以使用man shutdown命令。
2）shutdown -h now 现在立即关机
3）shutdown -r now 现在立即重启
4）shutdown -r +3 三分钟后重启
5）shutdown -h +3 "The System will shutdown after 3 minutes" 提示使用者将在三分钟后关机
6）shutdown -r 20:23 在20：23时将重启计算机
7）shutdown -r 20:23 & 可以将在20：23时重启的任务放到后台去，用户可以继续操作终端


