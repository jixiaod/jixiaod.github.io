---
title: Relearning PHP (1) - 为什么php文件尾不闭合标记 ?>
tags:
  - PHP
categories:
  - PHP
date: 2015-04-10 16:33:17
---

初学php的时候踩过这个坑，确实对初学者是个很难debug的问题。经大神指点说：“只要删除文件结尾的 ?&gt;，然后文件尾加几个空行就好！！”。试了下，果然解决问题。

但是为什么呢？

比如代码是这样一个php文件 a.php。在文件的最后的php结束标记 ?&gt; 后有空格和空行。
<pre class="lang:php decode:true" title="a.php">&lt;?php

class FooClass
{
public function foo()
{
echo "function foo";
}

}
?&gt;</pre>
在文件 b.php 中引用。
<pre class="lang:php decode:true" title="b.php">&lt;?php
include "a.php";
ob_flush();

header('HTTP/1.1 404 Not Found');
header("status: 404 Not Found");
echo "ok";
?&gt;</pre>
在header等函数调用之前，有输出，就会造成php的错误。

可以这样理解这个问题：其实可以把php的include的代码可以理解为俩个文件合并，于是中间的空格和空行还会保留。这些空格和空行是不会被php忽略的，会当做一种输出。如果没有结尾，则php语法会将空白忽略，从而不会发生错误。

下面是从php手册摘抄的，很有用[http://php.net/manual/zh/language.basic-syntax.php](http://php.net/manual/zh/language.basic-syntax.php "http://php.net/manual/zh/language.basic-syntax.php")

当解析一个文件时，PHP 会寻找起始和结束标记，也就是 <!--?php 和 ?-->，这告诉 PHP 开始和停止解析二者之间的代码。此种解析方式使得 PHP 可以被嵌入到各种不同的文档中去，而任何起始和结束标记之外的部分都会被 PHP 解析器忽略。

PHP 也允许使用短标记 &lt;? 和 ?&gt;，但不鼓励使用。只有通过激活 php.ini 中的 short_open_tag 配置指令或者在编译 PHP 时使用了配置选项 --enable-short-tags 时才能使用短标记。

如果文件内容是纯 PHP 代码，最好在文件末尾删除 PHP 结束标记。这可以避免在 PHP 结束标记之后万一意外加入了空格或者换行符，会导致 PHP 开始输出这些空白，而脚本中此时并无输出的意图。

Note:
在以下情况应避免使用短标记：开发需要再次发布的程序或者库，或者在用户不能控制的服务器上开发。因为目标服务器可能不支持短标记。为了代码的移植及发行，确保不要使用短标记。

Note:
在 PHP 5.2 和之前的版本中，解释器不允许一个文件的全部内容就是一个开始标记 <!--?php。自 PHP 5.3 起则允许此种文件，但要开始标记后有一个或更多白空格符。</p-->

Note:
自 PHP 5.4 起，短格式的 echo 标记 &lt;?= 总会被识别并且合法，而不管 short_open_tag 的设置是什么。
