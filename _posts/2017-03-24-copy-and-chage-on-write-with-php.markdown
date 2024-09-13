---
layout: post
title: 理解 PHP 的写时复制和写时改变
date: 2017-03-24 11:45:33
categories: PHP
---

对于这样一段代码：

```php
<?php
$a = 1;
xdebug_debug_zval('a');
$b = $a;
xdebug_debug_zval('a');
```
output
```sh
tiger➜/opt/work/tmp» /opt/php.5.6.25/bin/php ref_count.php                                                                                                                                             [11:17:01]
a: (refcount=1, is_ref=0)=1
a: (refcount=2, is_ref=0)=1
```

第一行 `$a = 1`，第二行把 `$a` 赋值给 `$b`。这样的话，`$a` 和 `$b` 其实都是1，如果在内存中存两份的话，不仅多浪费一块内存，而且还多了分配和管理内存的开销。是的，PHP也是采取内存共享的策略，对于上面的一段代码，`$a` 和 `$b` 其实都是指向了一块共享内存，同一个 zval。

`refcount` 就是当前的zval被引用的计数，当第一行代码`$a=1;` 创建这个变量时，只有 `$a` 指向这个zval，所以 `refcount` 等于1。当`$b=$a` 执行时，变量 `$b`也指向了这个 zval，所以 `refcount` 加1。

现在我们来看看什么是**写时复制 Copy on Write**，看下面一段代码

```php
<?php
$a = 1;
$b = $a;
xdebug_debug_zval('a');
$b = 2;
xdebug_debug_zval('a');
```
output
```sh
tiger➜/opt/work/tmp» /opt/php.5.6.25/bin/php ref_count.php                                                                                                                                             [11:16:22]
a: (refcount=2, is_ref=0)=1
a: (refcount=1, is_ref=0)=1
```
代码第四行，我们对 `$b` 重新赋值 2。PHP 在修改变量之前会先检查当前 zval 的 `refcount` 是否大于1，原本 `$a` 和 `$b` 都指向同一个zval，`refcount`  > 1。PHP 就会复制出一个新的 zval 来，原来的 zval 的 `refcount` 减 1。使得变脸 `$a` 和 `$b` 分离，这个机制就是**写时复制** 。

再来看看什么是**写时改变 Change on Write**

```php
<?php
$a = 1;
xdebug_debug_zval('a');
$b =& $a;
xdebug_debug_zval('a');
$b = 2;
xdebug_debug_zval('a');
```
output
```sh
tiger➜/opt/work/tmp» /opt/php.5.6.25/bin/php ref_count.php                                                                                                                                             [11:33:20]
a: (refcount=1, is_ref=0)=1
a: (refcount=2, is_ref=1)=1
a: (refcount=2, is_ref=1)=2
```

这段代码执行后，`$a` 也会呗修改成2。当 `$b =& $a;` 执行时，`is_ref` 被设置为1。此时虽然 zal 的 `refcount` 是2，但是对 `$b` 重新赋值并不会触发写时复制，而是先判断了 `is_ref` 是否等于 1。`is_ref` 等于1 则不分离，这就是**写时改变**。

需要注意的是，我用的PHP的5.6.25版本，在PHP7中，由于zval的结构体进行了优化，所以并不适用。而且像 `debug_zval_dump` 也不好用了。

 >debug_zval_dump's refcount was already a bit broken before PHP 7 came along: since call-time pass-by-ref is not available, theoretically the refcount should always be 1 or 2, but that's not terribly helpful. Then PHP 7 started making more changes to how variables move around.

>Since 7.1.2 the example shows refcount(3), which is more useful but blatantly contradictory to the docs. https://3v4l.org/ntX3A In PHP 5.6 it shows refcount(1) which is less useful but agrees with the docs.



