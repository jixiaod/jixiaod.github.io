---
title: 'sed: 1: "...": invalid command code  on Mac OS'
tags:
  - mac
  - sed
categories:
  - 流程&工具
date: 2015-06-10 10:35:34
---

昨天因为项目中有很多文件的同一个变量需要批量替换成另一个，想用sed做这个。Linux 这样其实就可以了

```
~# sed -i "s/string_old/string_new/g" `grep -rl string_old ./`
```

Mac 会得到抛出这个错误

sed: 1: "...": invalid command code .

为什么呢，在 Mac 上用 man 查看sed命令
```
~# man sed

...

-i extension
Edit files in-place, saving backups with the specified extension. If a zero-length extension is given, no backup will be saved. It is not recommended to give a zero-length extension when in-place editing files, as you risk corruption or partial content in situations where disk space is exhausted, etc.

….
```

翻译：
就地替换文件，根据提供的扩展名保存源文件备份。如果不提供扩展名，则不备份。建议替换操作时提供文件备份的扩展名，因为如果恰巧磁盘耗尽的话，你将冒着原文件被损坏的风险。

所以，如果我们不需要备份的话，可以这样

```
~# sed -i "" "s/string_old/string_new/g" `grep -rl string_old ./`
```

或者要备份原文件

```
~# sed -i ".bak" "s/string_old/string_new/g" `grep -rl string_old ./`
```

算是分享一下遇到的坑

