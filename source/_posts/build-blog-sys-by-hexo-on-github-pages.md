---
title: 使用 Hexo 在Github Pages 搭建 Blog
date: 2016-05-15 21:44:17
tags:
  - hexo 
categories:
  - 流程&工具

---

Sae 的云豆快用光了，也不打算再冲值了，所以还是用个免费的比较好。Hexo + Github Pages 是个不错的方案。Hexo 是一个快速、简单，而且功能十分强大的博客框架。博主可以用 Markdown 来撰写博文，然后通过 Hexo 生成静态文件。而且 Hexo 有非常多而且非常漂亮的主题可用。

安装Hexo很简单，首先需要环境基础环境

- [Node.js](http://nodejs.org/)
- [Git](http://git-scm.com/)

然后只需要 NPM 安装 Hexo即可

```
~$ npm install hexo-cli -g
```

（PS：如果是 Mac 用户，还需要安装 Command Line Tools）

创建博客项目

```
~$ hexo init jixiaod.github.io
```

生成的目录结构如下

```
.
├── _config.yml
├── package.json
├── scaffolds
├── source
|   ├── _drafts
|   └── _posts
└── themes
```

需要修改下_config.yml 配置文件，里面的参数写得很明了，其中需要配置好 Github 仓库地址。博文是写在 source/_posts 目录内的markdown 文件。主题我选择了 maupassant-hexo。还安装了一些其他的插件：

```
~$ npm install hexo-renderer-jade --save
~$ npm install hexo-renderer-sass --save
~$ npm install hexo-migrator-wordpress --save
~$ npm install hexo-deployer-git --save
~$ npm install hexo-generator-feed --save
~$ npm install hexo-generator-sitemap
```

migrator 插件可以帮助把wordpress 导出的xml文件，导入到 Hexo 自动转换成 markdown 文件。大部分文章都是没问题的，部分文章可能会有问题，需要单独处理下。

文章写好后，可以在本地查看，运行 Node.js 服务

```
~$ hexo server
```

可以在浏览器随时查看文章的板式，确定没问题，再去生成静态页面。

```
~$ hexo generate
```

然后发布到 Github Pages

```
~$ hexo deploy
```
最后添加配置 CNAME 文件，绑定自己的域名。需要注意的是，Hexo 都是通过 Hexo 的命令 （deploy）去发布代码到 Github。所以像 CNAME 文件、README文件是不能通过 deploy 发布到Github的。

需要把CNAME 文件放到 Hexo 的 source 目录，这样就能通过 generate 生成并发布到 Github。其他像README、favicon.ico 也都可以放到 source 目录下。


