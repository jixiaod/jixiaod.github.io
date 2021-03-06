---
title: HTTP Keep-Alive模式
tags:
    - HTTP
    - keepalive
categories:
    - 底层原理    

date: 2016-08-09 11:19:48
---

## 1、什么是 Keep-Alive 模式？

我们知道 HTTP 协议采用“请求-应答”模式，当使用普通模式，即非KeepAlive模式时，每个请求/应答客户和服务器都要新建一个连接，完成之后立即断开连接（HTTP协议为无连接的协议）；当使用 Keep-Alive 模式（又称持久连接、连接重用）时，Keep-Alive 功能使客户端到服务器端的连接持续有效，当出现对服务器的后继请求时，Keep-Alive功能避免了建立或者重新建立连接。

http 1.0 中默认是关闭的，需要在 http 头加入"Connection: Keep-Alive"，才能启用 Keep-Alive；http 1.1 中默认启用 Keep-Alive，如果加入"Connection: close "，才关闭。目前大部分浏览器都是用 http1.1 协议，也就是说默认都会发起 Keep-Alive 的连接请求了，所以是否能完成一个完整的 Keep-Alive 连接就看服务器设置情况。

## 2、启用 Keep-Alive 的优点

从上面的分析来看，启用Keep-Alive模式肯定更高效，性能更高。因为避免了建立/释放连接的开销。下面是[RFC 2616](http://tools.ietf.org/html/rfc2616)上的总结：

- By opening and closing fewer TCP connections, CPU time is saved in routers and hosts (clients, servers, proxies, gateways, tunnels, or caches), and memory used for TCP protocol control blocks can be saved in hosts.
- HTTP requests and responses can be pipelined on a connection. Pipelining allows a client to make multiple requests without waiting for each response, allowing a single TCP connection to be used much more efficiently, with much lower elapsed time.
- Network congestion is reduced by reducing the number of packets caused by TCP opens, and by allowing TCP sufficient time to determine the congestion state of the network.
- Latency on subsequent requests is reduced since there is no time spent in TCP's connection opening handshake.
- HTTP can evolve more gracefully, since errors can be reported without the penalty of closing the TCP connection. Clients using     future versions of HTTP might optimistically try a new feature, but if communicating with an older server, retry with old   semantics after an error is reported.

[RFC 2616](http://tools.ietf.org/html/rfc2616)（P47）还指出：单用户客户端与任何服务器或代理之间的连接数不应该超过2个。一个代理与其它服务器或代码之间应该使用超过 2 * N 的活跃并发连接。这是为了提高 HTTP 响应时间，避免拥塞（冗余的连接并不能代码执行性能的提升）。

## 3、回到我们的问题（即如何判断消息内容/长度的大小？）

Keep-Alive 模式，客户端如何判断请求所得到的响应数据已经接收完成（或者说如何知道服务器已经发完了数据）？我们已经知道了，Keep-Alive 模式发送玩数据, HTTP 服务器不会自动断开连接，所以不能再使用返回EOF（-1）来判断（当然你一定要这样使用也没有办法，可以想象那效率是何等的低）！下面我介绍两种来判断方法。

### 3.1、使用消息首部字段 Conent-Length

顾名思义，Conent-Length 表示实体内容长度，客户端（服务器）可以根据这个值来判断数据是否接收完成。但是如果消息中没有 Conent-Length，那该如何来判断呢？又在什么情况下会没有Conent-Length呢？请继续往下看……

### 3.2、使用消息首部字段 Transfer-Encoding

当客户端向服务器请求一个静态页面或者一张图片时，服务器可以很清楚的知道内容大小，然后通过 Content-length 消息首部字段告诉客户端需要接收多少数据。但是如果是动态页面等时，服务器是不可能预先知道内容大小，这时就可以使用 Transfer-Encoding：chunk 模式来传输数据了。即如果要一边产生数据，一边发给客户端，服务器就需要使用 "Transfer-Encoding: chunked" 这样的方式来代替 Content-Length。

chunk 编码将数据分成一块一块的发生。Chunked 编码将使用若干个 Chunk 串连而成，由一个标明长度为 0 的 chunk 标示结束。每个 Chunk 分为头部和正文两部分，头部内容指定正文的字符总数（十六进制的数字）和数量单位（一般不写），正文部分就是指定长度的实际内容，两部分之间用回车换行 (CRLF) 隔开。在最后一个长度为 0 的 Chunk 中的内容是称为 footer 的内容，是一些附加的 Header 信息（通常可以直接忽略）。

Chunk编码的格式如下：

```
Chunked-Body = *chunk
                                    "0" CRLF
                                    footer
                                    CRLF
chunk = chunk-size [ chunk-ext ] CRLF
                  chunk-data CRLF

hex-no-zero = <HEX excluding "0">

chunk-size = hex-no-zero *HEX
chunk-ext = *( ";" chunk-ext-name [ "=" chunk-ext-value ] )
chunk-ext-name = token
chunk-ext-val = token | quoted-string
chunk-data = chunk-size(OCTET)

footer = *entity-header
```

即 Chunk 编码由四部分组成：

- 0 至多个 chunk 块
- "0" CRLF
- footer
- CRLF

而每个chunk块由：chunk-size、chunk-ext（可选）、CRLF、chunk-data、CRLF组成。

## 4、消息长度的总结

其实，上面 2 中方法都可以归纳为是如何判断 http 消息的大小、消息的数量。[RFC 2616](http://tools.ietf.org/html/rfc2616)对消息的长度总结如下：一个消息的 transfer-length（传输长度）是指消息中的 message-body（消息体）的长度。当应用了 transfer-coding（传输编码），每个消息中的 message-body（消息体）的长度（transfer-length）由以下几种情况决定（优先级由高到低）：

- 任何不含有消息体的消息（如1XXX、204、304等响应消息和任何头(HEAD，首部)请求的响应消息），总是由一个空行（CLRF）结束。
- 如果出现了 Transfer-Encoding 头字段 并且值为非“identity”，那么 transfer-length 由“chunked” 传输编码定义，除非消息由于关闭连接而终止。
- 如果出现了 Content-Length 头字段，它的值表示 entity-length（实体长度）和 transfer-length（传输长度）。如果这两个长度的大小不一样（i.e.设置了 Transfer-Encoding 头字段），那么将不能发送 Content-Length 头字段。并且如果同时收到了 Transfer-Encoding 字段和 Content-Length 头字段，那么必须忽略 Content-Length 字段。
- 如果消息使用媒体类型 “multipart/byteranges” ，并且 transfer-length 没有另外指定，那么这种自定界（self-delimiting）媒体类型定义 transfer-length 。除非发送者知道接收者能够解析该类型，否则不能使用该类型。
- 由服务器关闭连接确定消息长度。（注意：关闭连接不能用于确定请求消息的结束，因为服务器不能再发响应消息给客户端了。）

为了兼容 HTTP/1.0 应用程序，HTTP/1.1 的请求消息体中必须包含一个合法的 Content-Length 头字段，除非知道服务器兼容 HTTP/1.1。一个请求包含消息体，并且 Content-Length 字段没有给定，如果不能判断消息的长度，服务器应该用用400 (bad request) 来响应；或者服务器坚持希望收到一个合法的 Content-Length 字段，用 411（length required）来响应。

所有HTTP/1.1的接收者应用程序必须接受“chunked” transfer-coding (传输编码)，因此当不能事先知道消息的长度，允许使用这种机制来传输消息。消息不应该够同时包含 Content-Length头字段和non-identity transfer-coding。如果一个消息同时包含non-identity transfer-coding和Content-Length ，必须忽略Content-Length 。


原文链接：[HTTP Keep-Alive模式 - 吴秦（Tyler）](http://www.cnblogs.com/skynet/archive/2010/12/11/1903347.html)
