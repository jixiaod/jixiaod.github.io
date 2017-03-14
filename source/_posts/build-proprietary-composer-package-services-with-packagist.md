---
title: 使用 packagist 搭建私有的 composer包管理服务
tags:
  - composer
categories:
  - PHP
date: 2015-06-04 19:27:59
---

### 1.下载 [Packagist](https://github.com/composer/packagist)

```
~# git clone https://github.com/composer/packagist.git
```

### 2.建立配置文件

从源里复制一份配置文件

```
~# cd packagist
~# cp app/config/parameters.yml.dist app/config/parameters.yml
```

然后修改配置，其中 client_id 我是在 github 随便注册了一个 application (注意冒号后面有个空格,否则会报错)，因为我是准备用svn做包的托管服务。

github.client_id: e1cf8971709276647541

### 3.安装 php 需要 intl 扩展

zendframework/zend-i18n 2.0.8 需要php安装intl扩展，需安装icu4c

```
~# brew install icu4c
~# cd php_src_package/ext/intl
```

安装 php 的 intl 扩展

```
~# /opt/php/bin/phpize
~# ./configure  --with-php-config=/opt/php/bin/php-config --with-icu-dir=/usr/local/opt/icu4c
~# make
~# make install
```

在 php.ini 中添加 extension=intl.so


### 4.安装 Packagist 项目依赖

安装 composer

```
~# curl -sS https://getcomposer.org/installer | php
```

在正式安装依赖之前，最好先把 composer.lock 删除，从新去生成 composer 依赖信息。

```
~# php composer.phar install
```

成功的话，应该是下面的打印

```
tiger➜github/OT/packagist(master✗)» php composer.phar install                                                                                                    [16:49:29]
Loading composer repositories with package information
Installing dependencies (including require-dev) from lock file
Nothing to install or update
Generating autoload files
Clearing the cache for the dev environment with debug true
Installing assets using the hard copy option
Installing assets for Symfony\Bundle\FrameworkBundle into web/bundles/framework
Installing assets for Packagist\WebBundle into web/bundles/packagistweb
Installing assets for WhiteOctober\PagerfantaBundle into web/bundles/whiteoctoberpagerfanta
Installing assets for Nelmio\SolariumBundle into web/bundles/nelmiosolarium
```

### 5.安装数据库 & 部署web应用

先把数据库建好，数据库名同配置文件，下面的脚步不会帮我们建立数据库。。。。（坑了我一下）

```
~# app/console doctrine:schema:create
```

部署web目录

```
~# app/console assets:install
```

### 6.配置nginx


配置如下：

```
server {
        listen       80;
        server_name  pkg.lo;

        location ~ ^/(css|js|font|js|bundles)/ { 
            root /opt/work/github/OT/packagist/web;
        }

        location / {
            try_files $uri /app.php$is_args$args;
        }

        location ~ \.php$ {
            root           /opt/work/github/OT/packagist/web;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  app.php;
            fastcgi_param  SCRIPT_FILENAME  /opt/work/github/OT/packagist/web/$fastcgi_script_name;
            include        fastcgi_params;
        }

    }
```


### 7.使用 Packagist 建立账号，提交自己的php包


注册账号就不说了，登录自己的注册用户，然后提交自己的已经写好的php包。需要注意的是发布到 Packagist 的分支分别对应的是svn项目的 trunk 和 tags 下的子目录， 比如版本 1.9.2 对应 tags/1.9.2。如果你的 svn 项目地址是 svn://svn.domain/code/packages，目录按照

```
| trunk
          + | composer.json
          + | src
| tags
          + | 1.0.0
          + | 1.0.2
| branches
```

提交这个代码包到 Packagist 的话，只需提交 svn://svn.domain/code/packages即可，会帮你自动生成 tags 目录下对应版本和 trunk 开发版本

另外需要注意，目录下需要有 composer.json 文件，说明这个包的信息。文件内容如下：

```
{
        "name": “vender-name/package-name",
        "type": "library",
        "homepage": "http://your-domain",
        "description": “This is test package.",
        "license": “If you have."
}
```

### 8.如何使用包


在需要使用包的项目目录配置下建立 composer.json 文件，同使用公共的Packagist。只是多了使用私有包托管服务的部分，文件内容如下：

```
{
    "require": {
        "mpb/mpb": "1.9.2"
    },
    "repositories": [
    {
        "type": "svn",
        "url": "svn://svn.domain/code/packages/vender-name/package-name"
    },
    {"packagist": false}
    ]
}
```

最后，安装包依赖

```
~# php composer.phar install
```

算是为了摆脱“轮子哥”的称号吧，毕竟自己费劲扒拉开发的包管理工具不太好用且不太实用。Composer＋Packagist是非常好的解决方案，配置简单且文档详细。尽量使用开源成熟的技术，还是把自己有限的精力贡献到无穷的 事业吧。

That is all, thank you.


