---
title: Travis CI 持续集成 Hexo 的 Github Pages的博客
date: 2017-03-24 14:45:17
tags:
    - hexo
    - travis-ci
categories:
    - 流程&工具

---

之前重新梳理了 [Hexo 博客的发布流程](http://blog.100dos.com/2017/03/14/how-to-use-hexo-post-articles-on-multiple-pcs/)，可以还是觉得麻烦。毕竟操作太多，容易出错。于是想到了用 Travis CI 简化一下，效果不错，省去了不少步骤。现在只需要在 hexo 分支撰写 blog，然后push到github就可以了。Travis 会帮助完成剩下的merge hexo分支、生成静态文件、提交 master 这些工作。

首先，用 Github 账号创建 [Travis CI](https://travis-ci.org/) 账号，直接用 Github 账号登录，并赋予权限即可。并在项目列表选择并创建 Travis CI 项目 `jixiaod / jixiaod.github.io`项目。

接着，在 Github 的配置里生成 `Personal access tokens`，然后在Travis CI里配置的 Environment Variables 里配置添加，一会要在 `.travis.yml` 中使用。并设置 `hexo` 为默认分支，在 `git push origin hexo` 时，触发 travis  build。 

编写 `.travis.yml` 文件，参考[我的配置](https://github.com/jixiaod/jixiaod.github.io/blob/hexo/.travis.yml) 


``` 
language: node_js
sudo: required
node_js:
  - 5.4.0
cache:
  directories:
    - node_modules
before_script:
  - git clone --branch master https://github.com/jixiaod/jixiaod.github.io.git public
script:
  - npm run build
after_success:
  - cd public
  - git config user.name "Ji Gang"
  - git config user.email "ji.xiaod@gmail.com"
  - git add --all .
  - git commit -m "travis ci auto build"
  - git push https://$Personal_access_tokens@github.com/jixiaod/jixiaod.github.io.git master
branches:
  only:
    - hexo
```

具体Travis 使用参见[官方文档](https://docs.travis-ci.com)，针对以上配置的说明流程如下：

- before_script：检出 master 分支代码到 public 文件目录。需要知道的是，在此之前 travis 已经帮你把hexo代码检出来了，实际上 public 目录是在 hexo 的目录之下。
- script: `npm run build` 参见 [package.json](https://github.com/jixiaod/jixiaod.github.io/blob/hexo/package.json)，实际执行的是 `hexo generate`，从新生成了静态文件。
- after_success: 最后把所有修改提交到了 master 分支，我们是用 `$Personal_access_tokens` 获得的 github 权限。

现在发布一篇文章只需要：

```
~(hexo)$ hexo new XXXX
~(hexo)$ git add .
~(hexo)$ git commit -m 'xxx'
~(hexo)$ git push origin hexo
```

剩下的工作，travis 全都能搞定了，比原来简化了许多。

还有一个需要注意的是，第一次 build 的时候报了一个莫名其妙的错误，“No Rakefile found (looking for: rakefile, Rakefile, rakefile.rb, Rakefile.rb)”。后来发现是 `.travis.yml` 配置中 Nodejs 的版本写的有问题。所以 build 前检查 `.travis.yml` 是否书写正确很有必要，可以在[http://lint.travis-ci.org](http://lint.travis-ci.org) 检查是否有问题。

