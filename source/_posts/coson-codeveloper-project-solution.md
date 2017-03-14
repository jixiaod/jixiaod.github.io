---
title: 多人多子项目开发解决方案
tags:
  - svn
  - 流程
categories:
  - 流程&工具
date: 2013-04-25 23:25:30
---


先不说为什么要多人多子项目共同开发，这里暂且只提供我们的一种解决方案。以后可能会单写一篇来说为什么我们会把那么多子项目合并成一个大项目。

对于传统的svn目录结构，大概是

```
/release

/trunk

/branches
```

对于单项目，这种结构很合适。但是如果有N多项目都放到这个svn中，就会产生问题，这个问题是致命的。就是如果你们公司使用trunk下的代码作为测试环境，一个正在测试的子项目将会阻塞另一个子项目的发布。

可能你会不懂为什么会阻塞项目发布，举个例子：产品经理A提出开发需求给程序B，B正在处理A的需求功能开发。B开发完成，提交给测试进行测试。测试环境是由程序B的branches合并到trunk，实际测试的就是trunk下的代码。测试周期尚未结束，此时产品C提出新需求，而且是另外一个功能开发，非常紧急，然后程序B辛苦加班功能完成了C的需求功能模块。然后，非常悲剧的发现测试人员还没有测试完成，A的需求还没上线，C的需求如果想发布只能是跳过merge到trunk。因为此时已经无法提交trunk下的代码，trunk的代码还没有测试完成，是不能发布的。说到这里，你应该懂我的意思了。同一个项目都可能形成此种状况，更何况是一个大项目的子项目之间呢！！

于是，我们的方案

```
/release

/trunk

/boughs/project1

/boughs/project2

/boughs/project2

/branches/project1/1.0/**

/branches/project2/1.0/**

/branches/project3/1.0/**

/tags
```

boughs的英文含义是大树枝，我们在这里对boughs的定义就在trunk和branches之间。他是一个小主干，大树枝。看了这个svn目录结构我想你已经懂我的思路了，很简单，即把原来的测试环境trunk改为boughs下的子项目。这样子项目之间的冲突解决了，只不过测试环境的搭建和配置要复杂了，需要单独配置每个子项目。这样一改之前发布代码从trunk到release，为各个子项目的boughs到release。release还是统一的，如果有需要，可以定期从新建立各个boughs，以保证各个项目之间的关系。

为了方便，我们开发了测试服务器的代码发布工具 mass [https://github.com/jixiaod/mass](https://github.com/jixiaod/mass "https://github.com/jixiaod/mass")

