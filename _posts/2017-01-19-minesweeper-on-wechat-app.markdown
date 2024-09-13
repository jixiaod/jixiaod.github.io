---
layout: post
title: 扫雷 - 微信小程序
date: 2017-01-19 10:55:08
tags:
categories: WeChat

---

![](/assets/images/post/wechat-minesweeper.jpeg)
微信小程序这几天很火，9号正式发布，今天19号过了10天，到现在略有降温的趋势。个大厂商对微信小程序的态度很不看好，最激进的要数[罗辑思维]，直接下架了自己的[得到APP]。滴滴、京东等APP也只保留了最精简的功能，某些担心过于完善的功能会抢夺APP本身的用户。不过这也印证了小程序的初衷，小而精、用完即走。（并不否认腾讯微信平台确实流氓的事实）

>PS：墨迹天气也开发了微信小程序版本，并且在1月9号第一时间发布，欢迎使用。

作为技术人员，怎能不亲手试试小程序开发呢？扫雷 Minesweeper

## 实现思路：

* 如果不了解扫雷的游戏规则，请自行 Google
* 绘制一张 10*10 的地图，并且标注地雷和非地雷，并且需要用数字表示每个点周围地雷的数量
* 用 mineMap[x][y] 表示一个点位
    * mineMap[x][y] < 0 (代码中 == -1) 初始状态
    * 0 < mineMap[x][y] < 9 该点周围地雷的数量
    * mineMap[x][y] == 9 表示该点是地雷
    * mineMap[x][y] > 9 （代码中 == 10）表示该点插旗

## Github 
* [https://github.com/jixiaod/wechat-app-minesweeper](https://github.com/jixiaod/wechat-app-minesweeper)

## 如何跑起来？
* 下载 & 安装 [微信小程序开发工具](https://mp.weixin.qq.com/debug/wxadoc/dev/devtools/download.html) 
* 配置 wechat-app-minesweeper 代码目录到开发工具即可

## 玩法
* 需要注意的是，由于没有鼠标右键标记Flag，简单做了 Flag 切换，开启后，方可标记Flag
* 最初的想法是通过 tap 和 longtap 来区分扫雷和Flag，但是开发工具不能区分这俩个事件，只能作罢



