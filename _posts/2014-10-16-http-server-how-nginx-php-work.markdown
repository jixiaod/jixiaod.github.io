---
layout: post
title: http server原理，nginx与php之间是如何工作的
categories: Nginx PHP
date: 2014-10-16 19:38:57
---

Nginx ("engine x") 是一个高性能的 HTTP 和 反向代理 服务器，也是一个 IMAP/POP3/SMTP 代理服务器。 Nginx 是由 Igor Sysoev 为俄罗斯访问量第二的 Rambler.ru 站点开发的，第一个公开版本0.1.0发布于2004年10月4日。其将源代码以类BSD许可证的形式发布，因它的稳定性、丰富的功能集、示例配置文件和低系统资源的消耗而闻名。— 百度百科

当nginx接收到一个http请求时，通过配置文件找到对应的server。然后匹配server中的所有location，找到最匹配的。而在location中的命令会启动不同的模块去完成工作，比如rewrite模块、index模块。因此在nginx中模块可以看作真正的劳动工作者。nginx的模块是被编译到nginx中的，属于静态方式。启动nginx时，模块被自动加载。不像apache，把模块单独编译成so文件，在配置文件中指定是否加载。所以，单比模块加载方面，nginx也比apache速度上有提升。

那nginx是怎么调用php的呢？先看下面的nginx中关于php的配置

```
    location ~ \.php$ {
            root           /webpath;
            fastcgi_pass   127.0.0.1:9000;
            …
            ...
        }
```

这个location指令把以php为文件后缀的请求，交给127.0.0.1:9000处理。我想你看到这个应该猜到了，这是一个C/S架构东西。  而这里的IP地址和端口（127.0.0.1:9000）就是fastcgi进程监听的IP地址和端口。fastcgi是一个可伸缩地、高速地在http server和动态脚本语言间通信的接口。多数流行的http server都支持fastcgi，包括apache、nginx和lighttpd等。同时，fastcgi也被许多脚本语言支持，其中就有php。

那这个fastcgi的配置IP和端口从何而来呢？在php-fpm.conf中可以看到如下：

```
listen = 127.0.0.1:9000  #这个表示php的fastcgi进程监听的ip地址以及端口

pm.start_servers = 2
```

php-fpm作为fastcgi的进程管理器，可以有效控制内存和进程，并且平滑重载php配置。php5.3以后，php-fpm被集成到php的core中，默认安装，无须配置。

fastcgi进程管理器php-fpm自身初始化，启动主进程php-fpm和启动start_servers个fastcgi子进程。主进程php-fpm主要是管理fastcgi子进程，监听9000端口，fastcgi子进程等待请求。当客户端请求到达nginx时，nginx通过location指令，将所有以php为后缀的文件都交给 127.0.0.1:9000 来处理。php-fpm选择并连接到一个fastcgi子进程，并将环境变量和标准输入发送到fastcgi子进程。fastcgi子进程完成处理后将标准输出和错误信息返回。当fastcgi子进程关闭连接时，请求便告处理完成，等待下次处理。
