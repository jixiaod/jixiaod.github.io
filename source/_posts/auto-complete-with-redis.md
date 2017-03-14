---
title: redis 实现自动匹配搜索 Auto Complete with Redis
tags:
  - redis
categories:
  - PHP
date: 2012-05-10 12:03:38
---

目前需要实现一个站内搜索的功能，类似google，baidu实时匹配搜索内容。

1.安装redis

```
~# wget http://redis.googlecode.com/files/redis-2.4.13.tar.gz
~# tar zxvf redis-2.4.13.tar.gz
~# cd redis-2.4.13
~# make
```

启动redis服务

```
～# src/redis-server
```

测试命令行

```
～# src/redis-cli
```

具体命令介绍，可参考[http://manual.csser.com/redis/index.html](http://manual.csser.com/redis/index.html)

2.安装phpredis扩展

```
~# `wget --no-check-certificate http:``//github``.com``/owlient/phpredis/tarball/master` `-O phpredis.``tar``.gz`

~# tar  zxvf phpredis.tar.gz

~# cd phpredis

~# phpize

~# ./configure

~# make && make install
```

在php的lib目录 能够找到redis.so  ----> /usr/lib/php5/20090626+lfs/redis.so (我的安装环境ubuntu 11.10)

添加到php.ini

```
extension= /usr/lib/php5/20090626+lfs/redis.so
```

重启php-cgi

3.导入词库到redis存储脚本

词库文件words.txt 格式如下：

```
中国红酒网逸香
中国葡萄酒年均消费量
中国葡萄酒生厂商
中国年均葡萄酒个人消费量
中国葡萄酒产业迎来成熟期
中国葡萄酒勃艮第
中国烟台
```

```
/*
class redis
@author tiger <ji.xiaod@gmail.com>
*/
class redis_client
{
public $red;
public $params = array();
public function __construct(){}

public function vendor_init($params)
{
$this->params = $params;
$this->connect();
}

public function connect()
{
$this->red = new Redis();
$p = $this->params;
try{
$this->red->connect($p['redis_host'], $p['redis_port']);
}catch(Exception $e) {
die('RedisException : Can\'t connect to ' .$p['redis_host'].':'.$p['redis_port']);
}
}

/*
load dict file into redis store.
*/
public function load_dict( $file )
{
$rkey = $this->params['redis_key'];
if( !$this->red->exists($rkey) ) {
$lines = file($file);
foreach ( $lines as $str ) {

//echo $str;
$strLen = mb_strlen($str, 'utf-8');
for($i=1; $i &lt; $strLen; $i++ ){

$prefix = mb_substr ( $str, 0, $i*1, 'utf-8' );
$redis->zAdd($rkey, 0, $prefix);
}
$redis->zAdd($rkey, 0, $prefix.'*');

}
}else{
die('Redis key exists: ' . $rkey);
}

}

public function autocomplete( $prefix, $count=10 )
{
$r = $this->red;
$result = array();
$rangelen = 50;
$start = $r->zRank( 'dicts', $prefix );
if( !$start ) {
return $result;
//die(JSONP('', 10004, 'Prefix not exists'));
}
while( count($result) &lt; $count) {
$range = $r->zRange( 'dicts', $start, $start+$rangelen-1 );
$start += $rangelen;
if(!$range || count($range) == 0 ) break;
foreach($range as $entry) {
$minLen = min( strlen($entry), strlen($prefix) );
if ( substr($entry, 0, $minLen) != substr($prefix, 0, $minLen) ) {
$count = count($result);
}
if ( substr($entry, -1)=='*' && count($result) != $count){
array_push($result, substr($entry, 0, -1));

}
}

}
return $result;
}

}
```

