---
title: 如何调试 PHP 程序
date: 2016-08-29 17:52:26
tags:
    - debug
    - PHP
categories:
    - PHP
---

对于大部分 PHP debug 问题来说，只要会 echo、var_dump 可能就够了。但是还有一些其他的函数方法和 PHP 调试相关的知识需要了解。

## 打印输出调试


`echo` 输出一个或多个字符串。

`print` 输出一个字符串。

`print_r` 跟 `var_dump` 类似，也是查看数组或对象时使用。不同的是，不会输出额外的数据类型，格式比较整齐。

`printf` 输出格式化字符串，比如要输出浮点数的时候，可以指定输出服点数的精确长度。

```php
<?php
$float = (0.1+0.7) * 10;
$int = (int) $float;
var_dump($int);
printf("%.20f",$float);

// outputs
int(7)
7.99999999999999911182
```

`var_dump` 当查看数组或者对象时常用，会额外输出数据类型。

`var_export` 的输出可以直接当作php代码赋值个一个变量，而这个变量就会取得和被 `var_export` 一样的类型的值。需要注意的是，当变量类型为 resource 的时候， 是无法简单 copy 复制的。当 `var_export` 的变量是 resource 类型时， `var_export` 会返回 NULL。

`debug_zval_dump` 的输出跟 `var_dump` 类似，但是多了一个 refcount，记录一个变量被引用了多少次。

`debug_print_backtrace` 查看程序的调用栈，查找出错时的上下文。

使用以上方法时，根据具体 debug 场景，选择最合适的打印方法即可。

## 错误输出控制

在 php.ini 配置文件中，可以通过 `error_reporting`、`display_errors`、`display_startup_errors`、`log_error`、`track_errors`、`error_log`。

`error_reporting` 设置 PHP 的错误显示级别，PHP的错误显示级别的预定义常量：

| 值 | 常量 | 说明 | 备注 |
| -- | ---- | ---- | ---- |
|1   | E_ERROR (integer)  |  致命的运行时错误。这类错误一般是不可恢复的情况，例如内存分配导致的问题。后果是导致脚本终止不再继续运行。| |
|2   | E_WARNING (integer) |   运行时警告 (非致命错误)。仅给出提示信息，但是脚本不会终止运行。| |
|4   | E_PARSE (integer)  |  编译时语法解析错误。解析错误仅仅由分析器产生。 | |
|8   | E_NOTICE (integer) |   运行时通知。表示脚本遇到可能会表现为错误的情况，但是在可以正常运行的脚本里面也可能会有类似的通知。 | |
|16  |  E_CORE_ERROR (integer) |   在PHP初始化启动过程中发生的致命错误。该错误类似 E_ERROR，但是是由PHP引擎核心产生的。|  since PHP 4|
|32  |  E_CORE_WARNING (integer) |   PHP初始化启动过程中发生的警告 (非致命错误) 。类似 E_WARNING，但是是由PHP引擎核心产生的。  |  since PHP 4 |
|64  |  E_COMPILE_ERROR (integer) |   致命编译时错误。类似E_ERROR, 但是是由Zend脚本引擎产生的。 |   since PHP 4 |
|128 |   E_COMPILE_WARNING (integer) |   编译时警告 (非致命错误)。类似 E_WARNING，但是是由Zend脚本引擎产生的。   | since PHP 4 |
|256 |   E_USER_ERROR (integer)  |  用户产生的错误信息。类似 E_ERROR, 但是是由用户自己在代码中使用PHP函数 trigger_error()来产生的。 |   since PHP 4 |
|512 |   E_USER_WARNING (integer) |   用户产生的警告信息。类似 E_WARNING, 但是是由用户自己在代码中使用PHP函数 trigger_error()来产生的。 |  since PHP 4 |
|1024 |   E_USER_NOTICE (integer)  |  用户产生的通知信息。类似 E_NOTICE, 但是是由用户自己在代码中使用PHP函数 trigger_error()来产生的。  |  since PHP 4 |
|2048 |   E_STRICT (integer)  |  启用 PHP 对代码的修改建议，以确保代码具有最佳的互操作性和向前兼容性。|  since PHP 5 |
|4096 |   E_RECOVERABLE_ERROR (integer) |   可被捕捉的致命错误。 它表示发生了一个可能非常危险的错误，但是还没有导致PHP引擎处于不稳定的状态。 如果该错误没有被用户自定义句柄捕获 (参见 set_error_handler())，将成为一个 E_ERROR　从而脚本会终止运行。 |   since PHP 5.2.0 |
|8192 |   E_DEPRECATED (integer)  |  运行时通知。启用后将会对在未来版本中可能无法正常工作的代码给出警告。 |   since PHP 5.3.0 |
|16384|    E_USER_DEPRECATED (integer) |   用户产少的警告信息。 类似 E_DEPRECATED, 但是是由用户自己在代码中使用PHP函数 trigger_error()来产生的。 | since PHP 5.3.0 |
|30719 |   E_ALL (integer)  |  E_STRICT出外的所有错误和警告信息。  |  30719 in PHP 5.3.x, 6143 in PHP 5.2.x, 2047 previously |

即可以通过配置 php.ini 文件配置 `error_reporting` 等级，也可以通过内置函数`error_reporting()`来配置。

```php
<?php

// Turn off all error reporting
error_reporting(0);

// Report simple running errors
error_reporting(E_ERROR | E_WARNING | E_PARSE);

// Reporting E_NOTICE can be good too (to report uninitialized
// variables or catch variable name misspellings ...)
error_reporting(E_ERROR | E_WARNING | E_PARSE | E_NOTICE);

// Report all errors except E_NOTICE
error_reporting(E_ALL & ~E_NOTICE);

// Report all PHP errors (see changelog)
error_reporting(E_ALL);

// Report all PHP errors
error_reporting(-1);

// Same as error_reporting(E_ALL);
ini_set('error_reporting', E_ALL);

?>
```

`display_errors` 设置是否将错误信息作为输出的一部分显示到屏幕，或者对用户隐藏而不显示。

- 这是一个辅助开发的功能，建议不要在正式环境中使用；
- 尽管 `display_errors` 也可以在运行时设置 (使用 ini_set())， 但是脚本出现致命错误时任何运行时的设置都是无效的。 因为在这种情况下预期运行的操作不会被执行；
- 并且 `display_errors` 显示的错误信息内容是根据 `error_reporting` 设置的错误显示等级。

`display_startup_errors`  显示 PHP 启动过程中的错误信息。

- 即使 `display_errors` 设置为开启, PHP 启动过程中的错误信息也不会被显示。强烈建议除了调试目的以外，将 `display_startup_errors` 设置为关闭。

`log_error` 设置是否将脚本运行的错误信息记录到服务器错误日志或者 `error_log` 之中。

- 在正式环境，建议使用错误日志代替 `display_error`。以免打印错误信息，暴露服务器配置，且影响用户体验。

`track_errors` 记录最后一个警告／错误到变量 `$php_errormsg`中。

`error_log` 设置脚本错误将被记录到的日志文件。PHP 必须有改文件的写入权限，如果是 PHP-FPM 运行，则必须是 PHP-FPM 的运行用户有该文件的写入权限。

综上，在本地的开发环境的配置建议为：

```
error_reporting = E_ALL
display_errors = On
display_startup_errors = On
log_errors = On
track_errors = On
error_log = /tmp/php_error.log
```

线上正式环境配置建议为：

```
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
track_errors = Off
error_log = /tmp/php_error.log
```

## 断点调试

感兴趣的话，可以看看 Xdebug/DBGp 结合 Zend Studio 或 Eclipse 等 IDE。


