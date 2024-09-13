---
layout: post
title: Thrift - 跨语言的 RPC 开发框架
categories: PHP
date: 2015-12-30 19:40:47
---

Thrift 是一个轻量级、跨语言的开源RPC框架，并且能够根据 *.thrift 文件自动生成联合代码。Thrift 提供了整洁的数据传输、序列化和应用层处理。通过简单的接口定义语言，生成跨语言的的程序代码，该代码通过抽象栈构建了可供 RPC 使用的 Client 和 Server。开发者可以在生成的 Client 和 Sever 代码的基础上去实现自己的业务逻辑。

本文主要从 PHP 开发者的角度，去介绍 Thrift 的架构、开发和部署。

### IDL：接口定义文件

接口定义文件是 Thrift 开发的核心，定义了 RPC 过程中通信的数据结构和通信的接口方法定义等。

详细的接口定义可参考：

[Thrift interface description language](http://thrift.apache.org/docs/idl)
[Apache Thrift Features](http://thrift.apache.org/docs/features)
[Thrift Types](http://thrift.apache.org/docs/types)

以下部分可以对照 tutorial.thrift 文件查看。

### 数据类型

Thrift 脚本可定义的数据类型包括以下几种类型：

#### 基本类型：

因为 PHP 本身是弱类型的，所以这个主要是为了针对其他语言。

bool：1 位的布尔值，true 或 false，对应 Java 的 boolean
byte：8 位有符号整数，对应 Java 的 byte
i16：16 位有符号整数，对应 Java 的 short
i32：32 位有符号整数，对应 Java 的 int
i64：64 位有符号整数，对应 Java 的 long
double：64 位浮点数，对应 Java 的 double
string：未知编码文本或二进制字符串，对应 Java 的 String
binary：Blob字节数组

#### 结构体类型：

struct：定义公共的对象，类似于 C 语言中的结构体定义。在php中是一个对象，在 Java 中是一个 JavaBean

#### 容器类型：

list：一种类型的有序链表，对应 Java 的 ArrayList，PHP的数组。
set：一种类型的独立元素集合，对应 Java 的 HashSet。PHP 不支持集合，会当成 List。
map：对应 Java 的 HashMap，PHP 中的关联数组。

#### 异常类型：

exception：就是 Exception。

#### 服务类型：

service：对应服务的类和方法定义，参数及返回类型，可以返回 void 类型。关键字 oneway 可以加在没有返回的方法前，比如没有返回值的方法，就可以不用去等待服务器返回了。

### Thrift 的调用栈

+-------------------------------------------+
| Server |
| (single-threaded, event-driven etc) |
+-------------------------------------------+
| Processor |
| (compiler generated) |
+-------------------------------------------+
| Protocol |
| (JSON, compact etc) |
+-------------------------------------------+
| Transport |
| (raw TCP, HTTP etc) |
+-------------------------------------------+

### 传输层 Transport

Thrift 实现的PHP 传输层相对其他语言要简单，不包括像 TNonblockingTransport（使用非阻塞方式，用于构建异步客户端）。对应 PHP 传输层源代码在 lib/php/lib/Thrift/Transport，主要包括以下：

TSocket －－ 使用阻塞式 I/O 进行传输，是最常见的模式
TFramedTransport －－ 使用非阻塞方式，按块的大小进行传输，类似于 Java 中的 NIO

#### 协议 Protocol

可以在 Thrift 代码中找到可以选择的通信协议，比如 php可用的协议在源码包的 lib/php/lib/Thrift/Protocol 目录。建议选择传输数据采用二进制格式，相对 JSON 体积更小，对于高并发、大数据量和多语言的环境更有优势。

TBinaryProtocol －－ 二进制编码格式进行数据传输
TCompactProtocol －－ 高效率的、密集的二进制编码格式进行数据传输
TJSONProtocol －－ 使用 JSON 的数据编码协议进行数据传输
TMultiplexedProtocol －－多路复用

#### 处理层 Processor

负责输入输出数据处理的接口，对 Protocol 的处理。（该部分代码会根据 Thrift 的接口定义文件自动生成）

#### 服务器 Server

对应 PHP 服务器代码在 lib/Thrift/Server。

TSimpleServer －－ 单线程服务器端使用标准的阻塞式 I/O
TServerSocket.php －－ Socket 实现
TForkingServer.php －－ 多进程实现

理解以上就可以写自己的 Thrift RPC服务和客户端了，可以参考 thrift 的教程。这个是我写的一个 [demo](https://github.com/jixiaod/thrift-php-demo)。

