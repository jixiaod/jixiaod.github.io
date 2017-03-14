---
title: 如何使用 hexo 在多台 PC 发布文章？
date: 2017-03-14 12:11:57
tags:
    - hexo

categories:
    - 流程&工具

---

最近公司和家里各有一台电脑，有需求在俩台电脑上都能发布 Hexo 文章。怎么办呢？

[知乎上的回答提供了思路](https://www.zhihu.com/question/21193762)，即创建俩个分支 master 和 hexo，下面的方案大体一样，具体操作流程详细描述一下。如何在PC1上[创建 Hexo 项目](http://blog.100dos.com/2016/05/15/build-blog-sys-by-hexo-on-github-pages/)，可以参考之前的文章。如果像我一样已经有在线的 Github Pages，可以考虑重新创建 Project，这样可以保证 master 和 hexo 代码纯净。

重新部署 hexo：

1. 重新创建 hexo 项目 `hexo init blog.100dos.com` ，拷贝之前的 _config.yml、 theme、README.md、CNAME 等资源到新的hexo
2. 提交代码到master，然后创建 hexo 分支，切换到 hexo 分支
3. 确保 hexo 分支的代码 `hexo server` 运行时，跟你之前的博客一样
4. 提交 hexo 分支代码，切换到 master，`git merge hexo` 合并刚刚的修改（如果有的话）
5. 最后在查看 `hexo server` master 分支下的代码，没问题的话，准备提交github。如果有问题，在 hexo 分支修改，然后再 merge 到 master
6. 删除 Github 上的原Project
7. 提交 hexo 分支到Github，`git push origin hexo`
8. 部署 master 分支，`hexo d --g`
9. OK完成重新部署工作。

如何在其他电脑发布文章？

1. 检出代码 git clone git@github.com:jixiaod/jixiaod.github.io.git
2. 切换到 hexo 分支，创建文章 `hexo new xxxxx`，文章编写完成后，提交
3. 切换到master，合并hexo分支新编写的文章，`git merge hexo`
4. 部署 master 分支，`hexo d --g`，发布新文章成功

亲测，有效。可以查看[我的 Github Hexo 代码](https://github.com/jixiaod/jixiaod.github.io)。


