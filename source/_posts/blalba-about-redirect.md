---
title: 关于重定向的事儿
tags:
  - nginx
  - rewrite
categories:
  - Nginx
date: 2014-05-30 17:32:24
---

当网站遇到需要更换域名和框架修改，总是要涉及到重定向的问题。一般的方法是通过添加nginx的rewrite来实现。
具体在server里面，比如域名从www.aaa.com切换www.bbb.com

rewrite ^(.*)$ http://www.bbb.com$1 permanent;

路由修改就相对复杂一点，比如想做把原来框架下的路由模块单独出一个子域名

```
        if ($request_uri ~ ^/index.php/Book) {
            rewrite ^/index.php/Book(.*) http://book.aaa.com$1 permanent;
        }
```

而对于rewrite的标记，有以下四个：

last      表示rewrite，浏览器地址不变；
break   当前规则匹配完成后，就不在匹配其他规则，（nginx对于一次http请求，每次都会匹配对应server中的所有项，找出一个最匹配的执行。）跟last一样，浏览器地址不变；
redirect  返回302零时重定向状态码，浏览器会显示的跳转到重定向后的地址；
permanent  返回301永久重定向状态码，浏览器会显示的跳转到重定向后的地址。

做过SEO的人，对于他们辛苦维护的连接。为了在修改域名之后不影响PR，都会选择301重定向。对于google来说，如果一个URL跳转用的302，就会出现我A的连接，实际上显示B的内容的情况。这种情况就叫做URL劫持，导致之前的PR都白做了。所以搜索引擎官方基本都会强调用301来转移网站内容。

另外，如果想在PHP逻辑层面实现重定向用什么方法？
```
<?php
header("Location:http://www.aaa.com");
exit;
?>
```

默认的话，这种方式的默认的HTTP状态码是302，301怎么搞？

```
<?php
header("HTTP/1.0 301 Moved Permanently');
header("Location:http://www.aaa.com");
exit;
?>

or

<?php

// 301 Moved Permanently
header("Location:http://www.aaa.com",TRUE,301);

// 302 Found
header("Location:http://www.aaa.com",TRUE,302);
header("Location: http://www.aaa.com");

// 303 See Other
header("Location:http://www.aaa.com",TRUE,303);

// 307 Temporary Redirect
header("Location: http://www.aaa.com",TRUE,307);
exit;
?> 
```

