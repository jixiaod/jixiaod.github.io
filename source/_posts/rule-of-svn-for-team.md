---
title: svn 协作开发流程
tags:
  - svn
categories:
  - 流程&工具
date: 2015-08-17 16:28:47
---

&nbsp;

## 版本迭代发布：

1\. 分支（branch）开发完成，合并分支代码到主干（trunk）
2\. 所有人代码合并完成，开发自测通过，合并到发布版本（release）
3\. QA人员在测试服务器测试release，完成后发布到线上环境
4\. 如测试发现问题，重复以上步骤

## 紧急发布：

1\. 直接修改发布版本代码（release），测试通过后，直接更新到线上
2\. “第一时间”合并修改代码到trunk，保证代码统一

## SVN 目录结构

branches/[app name]/[version]/[username] 个人开发分支
trunk 协作开发主干
release 线上发布版本|生产环境版本|稳定版本|
tags 对比较重要的封板保存的版本|开发历史节点|

![svn 协作流程](http://www.100dos.com/assets/images/svn-dev.jpg)

## 1\. 创建新的开发分支

~# cd /your svn path/branches
~# svn mkdir foo/1.0
~# svn ci -m "create braches/foo/1.0"

从trunk 拷贝建立新分支

~# svn cp svn://svn.moji.com/project/trunk svn://svn.moji.com/project/branches/foo/1.0/tiger -m 'create branches/foo/1.0/tiger'

## 2\. 检出开发分支到本地

~# svn checkout svn://svn.moji.com/project/branches/foo/1.0/tiger

## 3\. 提交个人分支代码

分支代码修改后，就可以提交到。

~# svn up
~# svn commit -m 'fix XXX 的问题'

SVN作为版本工具，帮助我们提高开发效率。版本迭代开发期间，必须“每天”至少下班前要提交自己代码。且写清楚提交日志非常重要，如：

~# svn ci -m "添加了XXX的功能"
~# svn ci -m "修改了XXX的BUG"
~# svn ci -m "删除了XXX的功能"
~# svn ci -m "完善更新了XXX的功能"

且，尽可能按照功能开发分多次提交代码，保证每个版本记录开发的功能分离，以便日志查找及代码回滚。

原则：

1\. 写清楚这次提交做了哪些修改；
2\. 写清楚这次提交为什么要做这些修改；
3\. 确定这次提交只做一个修改，且不要把一次修改分多次提交，以确定这次提交的版本是一个有效版本；
4\. 最最重要，既要把svn这种版本工具当成备份工具来用，还要不仅仅是当成备份工具来使用。

## 4\. 合并trunk代码到个人分支

合并主干 trunk 代码到分支，保持分支代码与主干代码同步

~# cd path/branches/foo/1.0/tiger
~# svn merge svn://svn.moji.com/project/trunk

提交合并代码

~# svn commit -m 'sync merge from trunk'

注：sync merge 用来获取主干分支上所有的新更改。换句话说，目标分支从主干分支作为代码源 copy 以来所有的修改，被从主干分支同步到目标分支。Sync merge 合并代码时，会自动根据合并历史纪录去忽略已经被合并的修改，所以可以阶段性重复的去从源主干分主合并代码，保持目标分支代码最新。

## 5\. 合并分支代码到主干 trunk

分支所有开发工作完成后，需要合并左右的更改到主干分支。Reintegrate merge 是把分支合并回他的源主干分支。

~# cd /path/project/trunk
~# svn merge --reintegrate svn://svn.moji.com/project/branches/mall/1.0/tiger

提交分支合并代码

~# svn commit -m 'merge from branches/mall/1.0/tiger'

如果想只合并部分功能到主干trunk，或者是几个固定版本50、54、60

~# svn merge -c50,54,60 svn://svn.moji.com/project/branches/mall/1.0/tiger

或者是某个版本区间 50 ～ 60

~# svn merge -r50:60 svn://svn.moji.com/project/branches/mall/1.0/tiger

如何快速找到分支建立的版本号

~# svn log -v —stop-on-copy

## Merge合并问题：

### 合并符号表示：

A Added
D Deleted
U Updated
C Conflict
G Merged
E Existed
R Replaced

### 解决冲突 confilict

不建议在合并过程中尝试编辑冲突（即，出现冲突，选择稍后解决postone），合并之后，可以找到冲突来源的开发成员一起沟通解决。

合并之后，逐个resolved 冲突

~# svn resolved [conflict file]
