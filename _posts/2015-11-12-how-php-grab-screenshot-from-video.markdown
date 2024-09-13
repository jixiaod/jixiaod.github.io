---
layout: post
title: PHP 获取视频的预览截图
categories: PHP
date: 2015-11-12 12:22:10
---

[ffmpeg](http://ffmpeg.org/) 是一个非常快的视频音频转换器，也能从视频音频数据里抓取一段内容。Mac OS 下安装非常简单，只需

```
~# brew install ffmpeg
```

就能安装最新的版本。如果需要编译安装，也可以去官网下载安装包。

[php-ffmpeg](http://sourceforge.net/projects/ffmpeg-php/files/ffmpeg-php/) 是 ffmpeg 的 php 扩展，但是它从 2008-10-15 就没有再更新过，最新版本是 0.6.0。已经不兼容最新版本的 ffmpeg。不过用低版本的 ffmpeg （比如08年的某个ffmpeg版本）应该能够成功安装 php-ffmpeg，不过我并没有尝试，除非它将来还会持续更新。

获取视频截图的命令

```
~# ffmpeg -i input.mp4 -f mjpeg -ss 3 -t 0.001 -s 640x960 output.jpg
```

参数解析：

-i 输入的视频文件
-f 强制转换的格式，可通过

~# ffmpeg -formats

去查看所有支持转换的格式。

-ss 定位到视频的截图时间位置，单位是 “秒”
-t 截图的时间，上命令的意思就是第3秒开始，0.001s瞬间的截图。所以如果你的视频只有 3 秒，这条命令是截取不到任何图片的。
-s 图片的宽高尺寸，单位是像素

在php中执行

```
<?php
// php sample
$target_file        = '/tmp/input.mp4';
$target_img_file    = '/tmp/ouput.jpg';
$width              = 640;
$height             = 960;

exec("ffmpeg -i {$target_file} -y -f mjpeg -ss 3 -t 0.001 -s {$width}x{$height} {$target_img_file}");
```


