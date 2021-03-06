---
title: Relearning PHP (2) - php 的浮点数float
tags:
  - float
categories:
  - PHP
date: 2015-05-28 11:09:40
---

php有很多坑，但是并不妨碍他是最好的语言。其他语言对于浮点数处理同样有问题，这应该是个“共有坑”。不信可以用google搜索“java float 坑”或者“C++ float 坑”试试。做电商的同学，涉及到钱的方面，用到浮点数是难免的，可能会遇到类似的问题。这个坑是这样的

```php
<?php

$a = 146.40;
$b = 48.80;

if ($a == ($b * 3)) {
    echo "true";
} else {
    echo "false";
}
```

计算器计算 48.8 ＊ 3 ＝ 146.4，但是结果当然是false了。原因就是这个坑。官方文档的描述如下：

浮点数的精度

浮点数的精度有限。尽管取决于系统，PHP 通常使用 IEEE 754 双精度格式，则由于取整而导致的最大相对误差为 1.11e-16。非基本数学运算可能会给出更大误差，并且要考虑到进行复合运算时的误差传递。
此外，以十进制能够精确表示的有理数如 0.1 或 0.7，无论有多少尾数都不能被内部所使用的二进制精确表示，因此不能在不丢失一点点精度的情况下转换为二进制的格式。这就会造成混乱的结果：例如，floor((0.1+0.7)*10) 通常会返回 7 而不是预期中的 8，因为该结果内部的表示其实是类似 7.9999999999999991118...。
所以永远不要相信浮点数结果精确到了最后一位，也永远不要比较两个浮点数是否相等。如果确实需要更高的精度，应该使用任意精度数学函数或者 gmp 函数。

关于浮点数比较可以有几个办法如下：

```php
<?php
$a = 146.40;
$b = 48.80;

// 取适当精度
if (round($a, 2) == round($b*3, 2)) {
    echo "true";
} else {
    echo "false";
}

// 相减的差值非常小
$epsilon = 0.000001;
if (abs($a-$b*3) &lt; $epsilon ) {
    echo "true";
} else {
    echo "false";
}
```

