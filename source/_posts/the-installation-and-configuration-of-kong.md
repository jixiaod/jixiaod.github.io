---
title: Kong 的安装和配置
date: 2016-07-25 14:16:10
tags:
    - kong
categories:
    - Nginx
---

## 安装
[官方安装文档](https://getkong.org/install/) 写的很详细，个人尝试了以下方法，均能顺利安装。 


* CentOS Install： https://getkong.org/install/centos/
* OS X Install： https://getkong.org/install/osx/ (https://getkong.org/install/osx/)
    * brew install： https://github.com/Mashape/homebrew-kong
* 编译安装：https://getkong.org/install/source/

#### 安装 Kong 的 rpm 包

// 查看CentOS版本，官方下载对应版本的 rpm 包

```
[lan_dev@v194 ~]$ cat /etc/redhat-release 
CentOS release 6.6 (Final) 
```

下载对应 CentOS 版本的 rpm 文件，之后执行 

```
~$ sudo yum install epel-release 
~$ sudo yum install kong-0.8.3.*.noarch.rpm —nogpgcheck 
```

## 配置数据存储

配置 Kong 需要连接的数据库存储，同时支持 PostgreSQL 9.4+ 或 Cassandra 2.2.x 作为它的存储服务。 

打开配置文件 

```
~$ sudo vim /etc/kong/kong.yml 
```

修改如下所在行的配置（PostgreSQL 安装配置可查看文档 [PostgreSQL 安装与配置](http://blog.100dos.com/2016/08/01/postgresql-install-and-use) ）

```
database: postgres 
postgres: 
 host: "127.0.0.1" 
 port: 5432 
 database: kong 
 user: "kong" 
 password: "123456" 
```

启动 Kong 

```
~$ kong start 
# Kong is running 
~$ curl 127.0.0.1:8001 

~$ kong stop 
~$ kong reload 
```

启动时，如果报错

```
[lan_dev@v194 ~]$ kong start
[INFO] kong 0.8.3
[INFO] Using configuration: /etc/kong/kong.yml
[INFO] Setting working directory to /usr/local/kong
[INFO] database...........postgres host=127.0.0.1 database=kong user=kong password=123456 port=5432 
[INFO] Leaving cluster..
[ERR] 错误: 函数 to_regclass(unknown) 不存在 (8)
[ERR] Could not start Kong
```

是因为PostgreSQL 版本太低，安装 PostgreSQL 9.4+ 以上版本。


## 添加API

添加你的具体业务 API 服务到 Kong 中，Kong 通过 RESTful API 来管理具体的Kong 实例。具体请求如下，Kong 管理的 API 在8001 端口。请求配置如下： 

```
~$ curl -i -X POST \ 
 --url http://localhost:8001/apis/ \ 
 -d 'name=coapi' \ 
 -d 'upstream_url=http://co.moji.com/' \ 
 -d 'request_host=co.moji.com' \ 
 -d 'strip_request_path=true' \ 
 -d 'request_path=/coapi' 
```

成功后，可测试： 

```
~$ curl -i -X GET --url http://localhost:8000/coapi/api/cola/getTimes?activityid=MC2016062101 
```

请求成功表示 Kong 已经路由请求到我们配置的 upstream_url 地址。这里我们选择了一种简单的适合我们的配置方式，路由方式可以分以下英文原文的俩种。Proxy Reference (https://getkong.org/docs/0.8.x/proxy/)

How does Kong route a request to an API? 
When receiving a request, Kong will inspect it and try to route it to the correct API. In order to do so, it supports different routing mechanisms depending on your needs. A request can be routed by: 

- A DNS value contained in the Host header of the request. 
- The path (URI) of the request.

我们的从 KONG 路由到业务的 API 使用： path URI 的方式请求 ＋ 设置 strip_request_path 为 true 

## 开启 KONG 插件

插件的可扩展性是 Kong 的核心思想之一，可以非常便利的通过插件让你的 API 获得新的特性。 

这里是 Kong 所有可用的插件 (https://getkong.org/plugins/)，下面是简单添加一个 key-auth 插件。 

```
~$ curl -i -X POST \ 
 --url http://localhost:8001/apis/coapi/plugins/ \ 
 --data 'name=key-auth' 
```

再次请求，已经不能访问了 401 Unauthorized。 
```
~$ curl -i -X GET --url http://localhost:8000/coapi/api/cola/getTimes?activityid=MC2016062101 
```

## 添加 Consumers

现在已经配置了 key-auth 插件，还需要添加 consumer 到 API，才能继续通过 Kong 代理请求。Consumer 在调用API时，与单个用户请求关联，能被用来跟踪、访问管理等等。 

建立一个用户名称为Jason 的 consumer，下面请求命令成功之后，Kong 还会为Jason 用户建立一个唯一的 custom_id。 

```
~$ curl -i -X POST \ 
 --url http://localhost:8001/consumers/ \ 
 --data "username=Jason" 
```

然后再为刚刚建立的用户 Jason 创建一个 key-auth 插件的 key。 

```
~$ curl -i -X POST \ 
 --url http://localhost:8001/consumers/Jason/key-auth/ \ 
 --data 'key=18b4ccb1a20076813c208d8e8a281a94' 
```

成功之后，再次访问： 

```
~$ curl -i -X GET --url http://localhost:8000/coapi/api/cola/getTimes?apikey=18b4ccb1a20076813c208d8e8a281a94&activityid=MC2016062101 
```
PS：apikey 必须写在 url 的第一个参数，否则会报“No API Key found in headers, body or querystring”的错误。 

## 用到的插件 RESTful API 配置

Basic Authentication － 浏览器弹框需要输入用户名密码才能访问…… 

```
~$ curl -X POST http://localhost:8001/apis/tianqi/plugins \ 
 --data "name=basic-auth" \ 
 --data "config.hide_credentials=true" 

~$ curl -X POST http://localhost:8001/consumers/Jason/basic-auth \ 
 --data "username=user123" \ 
 --data "password=secret" 
```

IP Restriction － IP 限制，黑名单、白名单。支持单IP、多IP、IP区间等配置。 

```
~$ curl -X POST http://localhost:8001/apis/tianqi/plugins \ 
 --data "name=ip-restriction" \ 
 --data 'config.blacklist=192.168.20.156' 
```

Rate Limiting － 以下是限制一分钟内只允许同一个IP 有5个请求，一小时内10000个请求 

```
~$ curl -X POST http://localhost:8001/apis/tianqi/plugins \ 
 --data "name=rate-limiting" \ 
 --data "config.minute=5" \ 
 --data "config.hour=10000" 
```

Request Size Limiting － 防止 DOS 攻击，限制访问的请求body 大于多megabytes 的请求。 

~$ curl -X POST http://localhost:8001/apis/tianqi/plugins \ 
 --data "name=request-size-limiting" \ 
 --data "config.allowed_payload_size=128" 











