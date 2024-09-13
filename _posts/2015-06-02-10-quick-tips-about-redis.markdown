---
layout: post
title: "Redis使用的10个小贴士"
date: 2015-06-02 16:32:45
categories: 技术 Redis

---

Redis在当下的技术圈自然是非常火的。从Antirez的个人小项目，发展到现在能达到工业标准的内存数据存储。伴随而来的，有很多人认可的正确使用redis的优秀实践。下面我们将会一起探索10个redis正确使用的小贴士。

## **1.不要使用 KEYS ***

好吧，在文章的开头对你大喊大叫不是个好的方式，但是这个确实是很重要的一点。很多时候，当我查看一个redis实例，执行commandstats（下面会提到，查看redis状态的命令），一个非常刺眼的KEYS出现在眼前。为了能让大家看懂，用代码举例比较好，伪代码如下：

```php
for key in 'keys *':
  doAllTheThings()
```

但是如果数据有1300w那么多，查询就会变的很慢。因为KEYS是O(n)，n是keys返回的行数，复杂度时跟数据库大小相关的。同时，在查询期间，其他查询都是被阻塞的。

取而代之，[SCAN](http://redis.io/commands/scan)允许查询以增量的方式调用，是一种更好的方式去模糊匹配。以迭代的方式，直到你发现了最终匹配结果，可以人为的控制查询操作的执行和停止。

## **2.如何知道是什么让redis变慢？**

因为redis没有冗长的日志，使得跟踪查询实例到底执行的如何变的困难。幸运的是，Redis提供了commandstat命令给你展示这个：

```
127.0.0.1:6379> INFO commandstats
# Commandstats
cmdstat_get:calls=78,usec=608,usec_per_call=7.79
cmdstat_setex:calls=5,usec=71,usec_per_call=14.20
cmdstat_keys:calls=2,usec=42,usec_per_call=21.00
cmdstat_info:calls=10,usec=1931,usec_per_call=193.10
```

这个能给你一个所有查询执行情况的分析。查询被执行了多少次，执行的总时间和平均时间。

如果想要重置状态的，得到一个新的状态统计的话，只需要执行 CONFIG RESETSTAT。

（译者注：我本机的redis-cli无法执行info commandstats，google下说是2.6版本之后都可以，不知道为啥。）

## **3.使用REDIS-BENCHMARK做性能测试，但不是绝对的**

Redis的作者这么说，“就像在下雨天，检查法拉利赛车的清洁挡风玻璃一样的去评估Redis的性能”。很多人问过我，为什么他们的Redis的测试结果不是很理想？这个真的有很多原因，需要看具体场景，比如：

- 我们在什么配置的客户端上跑Redis？
- 是不是版本不一样？
- 我们将要执行的应用程序跟我们做的Redis性能测试有可比性吗？

[REDIS-BENCHMARK](http://redis.io/topics/benchmarks)的测试结果能给我们了一个很好的参考标准，以至于能够发现我们自己搭建的Redis服务是否正常 。但是这个不能作为一个真正的负载测试。负载测试应该是针对我们真正的应用的环境，越接近真实的应用环境越好。

## **4.使用 Hashes**

跟hashes一起做朋友是非常美妙的，只要你给hashes机会，就能惊喜的发现他是多么的不可思议。我曾经不止一次看到键值设计如下：

```
foo:first_name
foo:last_name
foo:address
```

在上面的例子里，foo应该是存储一个用户的用户名。其中的每个值都是被分开了。这样容易出错，而且也添加了一些不必要的键值。如果这里用Hash，就能简单许多：

```
127.0.0.1:6379> HSET foo first_name "Joe"
(integer) 1
127.0.0.1:6379> HSET foo last_name "Engel"
(integer) 1
127.0.0.1:6379> HSET foo address "1 Fanatical Pl"
(integer) 1
127.0.0.1:6379> HGETALL foo
1) "first_name"
2) "Joe"
3) "last_name"
4) "Engel"
5) "address"
6) "1 Fanatical Pl"
127.0.0.1:6379> HGET foo first_name
"Joe"
```

## **5.设置TTL！**

如果可能的话，利用好键值的生命周期。一个很好的应用场景是，存储临时的用户认证信息。比如OAUTH，当我们想要设置一个用户的认证签名值的时候，会给这个值设置一个过期时间。当设置这个值的时候，加上过期时间，Redis会帮你清理这个值！就不再需要KYES* 循环取出来再删除了。。。

## **6.选择正确的清理策略**

上面提高了清理键值，我们现在说说这个。当Redis被写满，会尝试清理键值。这个会根据你的Redis配置，如果你的Redis中存在过期的键值，我强烈建议用 volatile-lru。另外一种情况，把Redis作为缓存使用，没有过期的键值设定，建议使用 allkeys-lru。可以查查关于[eviction policies](http://redis.io/topics/lru-cache#eviction-policies)文档，看看所有的配置选项。

## **7.如果你的数据非常重要，请使用 Try/Except**

如果数据是不是真的写入到Redis非常非常重要，还是强烈建议使用try/except。因为大多数Redis客户端被配制成“fire and forget”（打完枪就忘，读者自己体会下），尽管数据是否真正被写入确实是有必要考虑的。这种情况下，你的Redis调用的复杂度其实也没有增加多少，而且你还能够确保你的重要数据被写入。

## **8.不要只“虐”一个Redis实例**

如果可能的话，拆分工作负载到多个Redis实例。Redis的集群功能在3.0.0版本之后可以使用。Redis集群会根据键值的范围去拆分键值到Redis主库和从库的集群中。这里有详细的[Redis集群介绍](http://redis.io/topics/cluster-spec)，[这个是集群使用的教程](http://redis.io/topics/cluster-tutorial)。如果你不考虑集群，命名空间或者分散你的键值到多个实例也是个不错的选择。在redis.io上还有一篇亚马逊如何处理他们数据存储的[文章](http://redis.io/topics/partitioning)。

## **9.越多的CPU核心越好吗？**

当然不是！Redis现在和将来都将是单线执行的。就算开启了持久话，至多也就消耗俩个核（持久话会建立另外一个进程）。或者打算在一台服务器上运行多个Redis实例，希望你是因为测试环境需要才这么做的。所以，你不需要单纯的Redis服务器的CPU核数多于俩个。

## **10.高可用**

Redis 已经通过严谨完备的测试，很用户已经在生产环境中使用它（当然也包括[ ObjectRocket ](https://objectrocket.com/)环境）。如果在你的应用中非常依赖Redis，你需要考虑一个高可用的解决方案保证应用正常。如果你不希望自己去维护，ObjectRocket 提供7*24小时的高可用平台服务，试试看。（最后一段纯广告）


英文原文：[http://objectrocket.com/blog/how-to/10-quick-tips-about-redis/](http://objectrocket.com/blog/how-to/10-quick-tips-about-redis/)
