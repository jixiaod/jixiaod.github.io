---
title: Kong 介绍
date: 2016-07-25 14:01:05
tags:
    - kong
categories:
    - Nginx
---

## 简介
Kong 是开源的高性能、高可用，基于 Nginx 的接口管理中间层，并且能通过 Kong 管理和扩展你的 API 接口和微服务。包含很多功能强大的插件，HTTP基本认证、秘钥认证、IP黑白名单限制、CORS、API 请求限流、限制请求包尺寸、请求转发、TCP、UDP、文件日志、以及 nginx 监控等。Kong的插件使用 Lua 编写，能减少开发者基于 Nginx 开发接口时的复杂度和开发时间。

- RESTful 的接口管理
    - 建立在 Nginx 之上，Kong 能够完全通过简单的RESTful 接口来操作管理；
- 面向插件
    - 把你的服务放到 Kong 的后面，然后只需执行简单的命令，就能使用功能强大的插件；
- 支持多种平台和环境
    - Kong 几乎可以运行在任何环境，云服务或者预置系统，单个服务器、虚拟机，或者跨多个数据中心的部署。


## 为什么要使用 Kong ？

传统的 API 接口服务的架构大致如下：

![](/images/kong-introduction/without-kong.png)

- 通用的功能在多个 API 服务之间有冗余
- 整个系统是一个整体，很难维护
- 在不影响其他服务的情况下，很难再继续扩展
- 由于系统的限制，开发效率不高


使用 Kong 的架构：

![](/images/kong-introduction/with-kong.png)

- 以 Kong 为中心，并且结合 Kong 的插件功能集成到一起
- 能够随意扩展，构建高效的分布式架构
- 通过简单的命令就可以在 Kong 上通过插件的方式扩展功能
- 开发团队能够更多的专注产品开发，Kong 能够帮你去解决其他问题


## Kong 有两个核心功能组件：

- Kong Server ：基于 nginx 的服务器，用来接收 API 请求。
- Apache Cassandra ：用来存储操作数据，并且从 Kong 0.8.3 开始支持PostgreSQL做为数据库存储。

了解更多

- Github :  https://github.com/Mashape/kong
- 官方网站：https://getkong.org




