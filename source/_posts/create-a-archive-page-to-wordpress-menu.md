---
title: Wordpress 添加一个文章归档页面
tags:
  - wordpress
categories:
  - 流程&工具
date: 2015-11-20 17:14:58
---

首先要说的是，在 [wordpress](https://wordpress.org/) 上即可找到大部分你想要的 Themes 和 Plugins，安装和使用都很方便，具体查查文档应该都会弄，很简单。今天有朋友问我，我的“文章归档”页面时怎么做出来的？其实也很简单。

### 1\. 写好 PHP 模版代码和需要的 CSS

[我的放到这里了](https://github.com/jixiaod/wordpress-archive)，把 gihub 的代码 clone 下来。需要把 style.css 的内容添加到你正在使用的模版的 style.css 底部即可。archive.php 放到 page-templates 目录下即可。注意的是 archive.php 文件内容开头的注释是必须的，如下
```
<?php
/**
* Template Name: Archive Page Template
*
*/
```
这个标识了模版名称。这样将能在wordpress 的后台控制 -&gt; 外观 -&gt;编辑 的右侧列表找到这个模版。

### 2.添加一个新的 Page 页面

在后台控制 -&gt; 页面 -&gt; 新建页面，添加一个新的页面。编辑好标题及想要的url 固定链接，不需要编写任何文章内容。在右侧的“页面属性”，选择刚才做好的模版。发布！就可以在前台查看这个 Page 了。

### 3.添加该页面到 Menu

在页面-&gt; 菜单 -&gt; 选择刚才编辑的 Page，添加到菜单列表即可。

done！
