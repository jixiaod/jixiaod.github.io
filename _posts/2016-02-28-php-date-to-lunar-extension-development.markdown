---
layout: post
title: PHP 转换农历 C 扩展开发
tags:
categories: PHP
date: 2016-02-28 19:10:55
---

本文主要是为了熟悉 PHP 扩展开发，开发一个农历扩展貌似并没有什么luan用。PHP 成功的原因之一是他拥有强大的扩展，并且能够让开发者灵活的开发自己的 PHP 扩展。致力于成为一个 LNMP Stack Expert 的我（一不小心又装B了）,当然不能错过，要学习专研的知识还有很多很多！！

### PHP 扩展开发

#### 扩展函数定义文件

先定义一个函数定义文件，比 thrift 的 IDL 文件要简单的多。函数定义文件定义扩展对外提供的函数原型。一般格式是一个函数一行。函数定义需要指定返回值和传入参数的类型，可以包括: bool, float, int, array等。农历算发的函数定义文件如下：

```
string datetolunar(int year, int month, int day);
```

当然也可以在同一个函数定义文件中定义多个函数，也可以定义一个类，这样就能够生成对应的函数类扩展骨架。比如：

```
class Lunar {
    string datetolunar(int year, int month, int day);
}
```

#### 生成 PHP 扩展骨架

在 PHP 的源码目录下的 ext/ 目录下有 ext_skel 脚本。用它可以根据刚刚定义的农历扩展函数定义文件 lunar.skel 生成扩展骨架。

```
~# ./ext_skel --extname=datetolunar --proto=lunar.skel
```

extname 表示生成的扩展名字，执行之后就会在 ext/ 目录下生成 datetolunar 目录。

```
tiger➜php-5.6.17/ext/datetolunar» ls [14:44:36]
CREDITS EXPERIMENTAL config.m4 config.w32 datetolunar.c datetolunar.php php_datetolunar.h tests
```

为了使扩展能够被编译，需要修改其中的 config.m4 文件，去掉虾面几行的注释（即 dnl）

```
PHP_ARG_WITH(datetolunar, for datetolunar support,
dnl Make sure that the comment is aligned:
[ --with-datetolunar Include datetolunar support])

dnl Otherwise use enable:

PHP_ARG_ENABLE(datetolunar, whether to enable datetolunar support,
dnl Make sure that the comment is aligned:
[ --enable-datetolunar Enable datetolunar support])
```

如果没有引用任何外部的 C 库的话，就不需要过多更改了。否则可能需要了解下这些

```
PHP_ADD_INCLUDE
PHP_ADD_LIBRARY_WITH_PATH
PHP_SUBST
PHP_NEW_EXTENSION
```

具体用法 google 下就好。

#### 编译

现在就已经可以编译这个扩展到你的 PHP 了（虽然并没有什么功能）。我一般会选择动态编译的方式，大部分开源的 PHP 扩展，我也会用这种方式，因为简单。

```
~# phpize
~# ./configure --with-php-config=/opt/php/bin/php-config
~# make
~# make install
```

之后就会生成 datetolunar.so 文件，添加到 php.ini 中添加 extension=datetolunar.so，就可以尝试调用这个扩展了。生成的骨架代码中有测试扩展的 PHP 文件，检查扩展是否成功编译到 PHP。

```
tiger➜php-5.6.17/ext/datetolunar» php datetolunar.php [14:31:26]
Functions available in the test extension:
confirm_datetolunar_compiled
datetolunar

Congratulations! You have successfully modified ext/datetolunar/config.m4. Module datetolunar is now compiled into PHP.
```

### 编写 C 代码

介绍了 PHP 扩展的开发流程之后，我们看看如何实现一个农历扩展。我们可能需要先大概了解一下农历算法。

#### 了解农历算法

农历算发基础知识

- [算法系列之二十：计算中国农历（一）](http://blog.csdn.net/orbit/article/details/9210413)
- [算法系列之二十：计算中国农历（二）](http://blog.csdn.net/orbit/article/details/9337377)

打开 datetolunar.c 文件能够看到如下的 hex_lunar 定义。

```
static int hex_lunar[] = {
0x04bd8,0x04ae0,0x0a570,0x054d5,0x0d260,0x0d950,0x16554,0x056a0,0x09ad0,0x055d2,
0x04ae0,0x0a5b6,0x0a4d0,0x0d250,0x1d255,0x0b540,0x0d6a0,0x0ada2,0x095b0,0x14977,
….
};
```

其中每一个 16 进制的数字表示是从 1900年～ 2050年的所有农历数据信息，把16进制转换成2进制，每一部分表示如下

-   1-4: 表示当年有无闰年，有的话，为闰月的月份，没有的话，为0。
-   5-16：为除了闰月外的正常月份是大月还是小月，1为30天，0为29天。注意：从1月到12月对应的是第16位到第5位。
-   17-20： 表示闰月是大月还是小月，仅当存在闰月的情况下有意义。

举个例子：

1980年的数据是： 0x095b0
二进制：0000 1001 0101 1011 0000
表示 1980 年没有闰月，从1月到12月的天数依次为：30、29、29、30 、29、30、29、30、 30、29、30、30。

1982年的数据是：0x0a974
0000 1010 0 1001 0111 0100
表示1982年的4月为闰月，即有第二个4月，且是闰小月。
从1月到13月的天数依次为：30、29、30、29、 29(闰月)、 30、29、29、30、 29、30、30、30。

#### 编写代码 & 调试

由于刚开始学习写 PHP 扩展，不太熟悉。我选择先写完并且调试好功能之后，再把代码复制到 PHP 扩展中。C 语言debug，推荐使用cgdb，能够边看代码边debug，比 gdb 方便很多。

编译

```
~# gcc -g lunar.c -o lunar
```

使用 cgdb 调试

```
~# sudo cgdb lunar
```

break - 设置断点
run - 运行程序
print - 打印变量
continue - 继续执行

PS：如果打印的数组很长，print 被简写的话，可以在 gdb 中通过

```
>> set print element 0
```

来设置。

#### 代码迁移到 PHP 扩展中

C 代码写完并且没问题之后，准备迁移到PHP的扩展中。在之前使用 ext_skel 脚本生成的骨架代码datetolunar.c 中，有自动生成的C函数 PHP_FUNCTION(datetolunar) 的定义。

```
PHP_FUNCTION(datetolunar)
{
int argc = ZEND_NUM_ARGS();
long year;
long month;
long day;

if (zend_parse_parameters(argc TSRMLS_CC, "lll", &year, &month, &day) == FAILURE)
return;

php_error(E_WARNING, "datetolunar: not yet implemented");
}
```

为了获得函数传递的参数，可以使用zend_parse_parameters()API函数。下面是该函数的原型：

```
zend_parse_parameters(int num_args TSRMLS_DC, char *type_spec, …);
```

第一个参数是传递给函数的参数个数。通常的做法是传给它ZEND_NUM_ARGS()。这是一个表示传递给函数参数总个数的宏。第二个参数是为了线程安全，总是传递TSRMLS_CC宏。第三个参数是一个字符串，指定了函数期望的参数类型，后面紧跟着需要随参数值更新的变量列表。因为PHP采用松散的变量定义和动态的类型判断，这样做就使得把不同类型的参数转化为期望的类型成为可能。例如，如果用户传递一个整数变量，可函数需要一个浮点数，那么zend_parse_parameters()就会自动地把整数转换为相应的浮点数。如果实际值无法转换成期望类型（比如整形到数组形），会触发一个警告。

了解这些之后，复制写好的 C 代码到函数中。需要做的只是再让 PHP 返回我们想要的结果就好。

#### 从PHP函数中返回值

这里返回一个字符串，我们用到的函数是 RETURN_STRING

```
char* ret = lunar_output;
RETVAL_STRINGL(lunar_output, strlen(ret), 1);
```

这是直接返回了一个静态字符串，如果最后一个参数设为0，会导致php在free这个字符串的时候出错。因为 PHP 是类型安全的脚本语言，对于RETURN_STRINGL或是RETURN_STRING返回的字符串，php会在适当的时候free掉，所以程序员要保证返回的字符串在堆里，能够free掉，这就是为什么动态分配就没事的原因。而：

```
char* ret = "hello world";
RETURN_STRINGL(ret, strlen(ret), 0);
```

这是直接返回了一个静态字符串，导致 PHP 在 free 这个字符串的时候出错。RETURN_STRINGL 和 RETURN_STRING 最后一个参数，如果是1，表示对第一个参数中的字符串在堆里复制一份返回，这样就没问题了。

扩展API包含丰富的用于从函数中返回值的宏。这些宏有两种主要风格：第一种是RETVAL_type()形式，它设置了返回值但C代码继续执行。这通常使用在把控制交给脚本引擎前还希望做的一些清理工作的时候使用，然后再使用C的返回声明 ”return” 返回到PHP；后一个宏更加普遍，其形式是RETURN_type()，他设置了返回类型，同时返回控制到PHP。下表解释了大多数存在的宏。


设置返回值并且结束函数 | 设置返回值 |  宏返回类型和参数
---------------- | -------------- | ---------- 
RETURN_LONG(l) |  RETVAL_LONG(l) |  整数
RETURN_BOOL(b) | RETVAL_BOOL(b) |  布尔数(1或0)
RETURN_NULL() |  RETVAL_NULL() |  NULL
RETURN_DOUBLE(d)  |   RETVAL_DOUBLE(d)  |   浮点数
RETURN_STRING(s, dup) |  RETVAL_STRING(s, dup) |  字符串。如果dup为1，引擎会调用estrdup()重复s，使用拷贝。如果dup为0，就使用s
RETURN_STRINGL(s, l, dup) |  RETVAL_STRINGL(s, l, dup) |  长度为l的字符串值。与上一个宏一样，但因为s的长度被指定，所以速度更快。
RETURN_TRUE |  RETVAL_TRUE | 返回布尔值true。注意到这个宏没有括号。
RETURN_FALSE  |   RETVAL_FALSE |    返回布尔值false。注意到这个宏没有括号。
RETURN_RESOURCE(r)  |  RETVAL_RESOURCE(r) |  资源句柄。

### WORK DONE

这样就完成了我们的 PHP 农历扩展。编译成功！！！（当然make的时候，可能会有问题，逐一解决就好）

#### 测试一下

```
tiger➜work/github/php-lunar-extension» php -r "echo datetolunar(2016,2,27);" [14:47:19]
丙申[猴]年 正月二十%
```

OK, Good~

#### 性能测试

实现同样功能的农历转换代码。第一个是php实现的农历函数，第二个是我们刚刚实现的PHP扩展，都执行10000次，性能提高了大概 86 倍（略激动～）。

```
tiger➜work/github/php-lunar-extension» php test.php [18:28:06]
>> Excute php function.
1.7234871387482
>> Excute php extension function.
0.022943019866943
```

扩展源代码在这里：https://github.com/jixiaod/php-lunar-extension

