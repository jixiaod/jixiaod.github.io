---
title: git 命令使用
tags:
  - git
  - gitlab
categories:
  - 流程&工具
date: 2013-08-06 14:42:14
---

前些天在服务器上搭建好了gitlab，想在团队推行git，逐步替换svn的使用。这样大家再也不需要linux系统管理员来帮忙创建项目和开通权限，都能够自己搞定，而且gitlab强大功能也能让代码review更加能够实行（虽然已经搭建了websvn，但是功能带单一）。

对于大多新的团队成员，如何能像svn一样检出代码可能是开始使用git的第一步：

首先，让gitlab的管理员，帮你创建一个账号，你登陆到gitlab，一般都使用ssh public keys来push和pull代码。使用ssh-keygen 生成ssh密钥。

~# ssh-keygen

~# cat ~/.ssh/id_rsa.pub

拷贝自己的ssh密钥，添加到gitlab的public key。

然后，新建本地git目录检出目录。

~# mkdir project

~# cd project

~# git init   // 初始化本地环境

~# git remote add origin git@githost:username/project.git   // 添加远程git地址，其中origin是给远程版本库起的别名，随便起。

~# git pull origin master  // 检出master分支代码到本地

这样本地开发环境的代码就检出到本地了。

==============================================================================

另git remote命令还有

~# git remote -v   // 查看当前使用的git 版本库地址

~# git remote add [name] [url]  // 添加远程版本库

~# git remote rm [name]  // 删除远程版本库

~# git remote set-url [name] [url]  //修改远程版本库

~# git pull [remoteName] [localBranchName]    // 拉去远程版本库代码

~# git push [remoteName] [localBranchName]   // 提交本地分支代码

==============================================================================

由于git的灵活性，本地的分支名可以与远程版本库不同。但为了团队协作不出问题，必须规定本地分支名与版本库分支名相同。还有远程版本库统一命名origin，分支目录结构

origin/release-[version]   // 正式发布版本

origin/master     // 开发主干（用于测试环境）

origin/bough-[son-project]  // 系统子项目主分支（用于多人多子项目测试环境）

origin/branch-[develper]-[version]   // 项目团队个人开发分支

==============================================================================

在添加远程版本库的前提下，如果想在本地添加远程版本库的其他分支，只需：

~# git pull origin branch-1.1    // 拉取版本库项目分支

~# git branch branch-1.1  // 创建本地分支

~# git checkout branch-1.1   // 本地切换分支开发环境

==============================================================================

分支合并，思想上和操作上跟svn的合并操作类似，但是确实比svn要简单的多！！

～# git branch   // 查看你当前所在分支，比如在master分支下，要合并branch-1.1到master

~# git merge branch-1.1  // 直接在master分支下执行，当然这只是在你的本地执行操作，没有影响到git远程版本库上的分支,如果出现冲突，解决方式跟svn merge类似。建议多人协作开发merge操作都在本地执行，然后再push到远程版本库。

另外：

～# git branch -r // 查看远程版本库的所有分支

~# git branch -d [branchName]   // 删除本地分支

~# git branch --help  //查看分支的用法

==============================================================================

git也有tag标签功能，有需求可以通过~# git tag --help 查看使用。

git的submodule功能对于团队以后的开发一定有很大帮助。<span style="font-size: medium;"><span style="line-height: 27px;">**
**</span></span>

~# git submodule add git@git-host/username/submodule.git include/core/**

&nbsp;
