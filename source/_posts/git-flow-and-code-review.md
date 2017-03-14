---
title: Git 使用 & Code Review 流程
date: 2016-06-15 13:59:34
tags: 
  - git
categories:
  - 流程&工具
---

1. 新建项目，并提交到 Github 生成第一个远程 master 版本
2. 项目组成员 fork 该项目到自己的本地仓库，然后  git clone 自己的本地仓库  master 到自己本地开发环境，
3. 并在本地创建自己的开发分支，如 branch1
4. 在自己的 branch1 分支开发完成后，提交 branch1 分支代码到本地仓库，并在 Github提交 PR（pull request） 到远程主仓库，并@相关开发人员进行 Code Review
5. 当所有人LGTM（Looks good to me） 之后，合并代码到远程主master
6. 或者大家都觉得这是个无用的 PR，则关闭该PR
7. 如果有异议，需要开发修改代码，提交修改后的 commit，直到所有人满意为止
8. 当所有人的该版本都合并到远程主仓库，视为此版本工作开发工作完成。可以用此版本部署进行测试并部署到生产环境
9. 继续版本功能迭代开发，需要 pull 拉取更新远程主仓库master 到本地 master
10. 并用本地 master 建立新的本地开发分支branch2，在 branch2 继续开发
11. 后续操作可跳转到第3步继续。

## 流程图
![git flow](http://ww2.sinaimg.cn/large/62d98a55jw1f5ed6qf1o0j213g10sae0.jpg)

## 说明

* up 是远程主仓库，origin 是本地仓库

```
tiger➜github/jixiaod/php-langspec-cn(master)» git remote -v                                                                                  [18:27:46]
origin    https://github.com/jixiaod/php-langspec-cn.git (fetch)
origin    https://github.com/jixiaod/php-langspec-cn.git (push)
up    https://github.com/100dos/php-langspec-cn.git (fetch)
up    https://github.com/100dos/php-langspec-cn.git (push)
```

* Code Review 主旨在能够形成良好的技术氛围和学习环境
* 提出问题和解决问题的言论要公平客观，只针对技术，不涉及个人
* 以上各个环节所有技术交流内容尽量在 GitLab 和 Pha 的 Comment 来做，减少使用微信或QQ
* 每个 PR 都是完备的，一个 PR 里 commit 的量要少而精，避免无意义的 commit
* 本地 master 需要在新的版本迭代开发前同步远程 master，避免以后出现冲突
* Code Review 需要@相关人员 包括
    * 负责该项目的所有开发成员
    * 小组技术Leader
* Code Review 常见英文缩写
    * LGTM（Looks good to me），表示认可这次PR，同意merge 合并代码到远程仓库
    * WIP （Work in progress），这个PR进行中。会有这种场景，一个大模块，先提交一个 PR 写下大致的代码架子。这样可以先 review 代码设计，然后一直在该 PR下修改提交，直达完成，最后合并。
    * IMO（In my opinion），在我看来，比较装逼的说法，慎用！


