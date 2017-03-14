---
title: 关于redis实现队列问题
tags:
  - redis
categories:
  - PHP
date: 2013-04-02 15:28:14
---

最近用redis的队列对接公司短信平台服务。对于redis如何实现队列服务，无非是rpop、lpush。网上资料很多，就不废话了，我要说说开发时遇到的问题。

代码上线后发现一个问题，redis队列长时间没有写入（时间不确定）。读取队列时，会出现redis队列确实rpop弹出内容，但是内容为空。查询redis的队列，发现已经空队列，确实弹出了message。

怀疑队列疆死所致，于是设置了一个激活时间（开始设置1800s）。以激活时间为周期往队列里写入冗余数据，保证队列可用。还是不行，怀疑激活时间过长，修改缩短到600s（10分钟）。还是不行，确认不是这个原因所致。

换个思路，现在用的链接redis的方法是connect，于是尝试长链接pconnect。结果确实没问题了。

```
class rQueue {

    public $redis = NULL;
    public function __construct($cfg) {

        try {
            $this->redis = new redis();
            $this->redis->pconnect($cfg['host'], $cfg['port']);
            if(isset($cfg['auth'])) {
                $this->redis->auth($cfg['auth']);
            }
        } catch(Exception $e) {
            echo $e->getMessage();
        }
        return $this->redis;
    }

    public function pop_queue($key) {
        return $this->redis->rpop($key);
    }

    public function in_queue($key, $val) {
        return $this->redis->lpush($key, $val);
    }

}
```

但是出现了俩个新问题，之前为了激活队列写了如下代码

```
           /**
            * @brief  计数超过redis队列的激活时间，写入队列
            */
            if ( $time_c >= ACTIVE_TIME ) {
                $queueO->in_queue($redis_cfg['key'], 0);
                $time_c = 0;
                echo "log >> redis queue active time loop again.\n";
            }
```

1.Fatal error: Uncaught exception ‘RedisException’ with message 'read error on connection'
2.每到一个ACTIVE_TIME时间，队列都弹出一个 ：1，我明明写入的是 0 啊！！！？

第一个问题可以通过设置PHP

```
ini_set('default_socket_timeout', -1);
```
另外保证redis.conf 中，timeout 设为0。 :)
第二个问题，解决办法是我把这段代码删掉了。。。。 :&lt;


!!!前几天发现，redis队列实现没有问题，出现的问题是mysql连接超时造成的！！特此更正！

