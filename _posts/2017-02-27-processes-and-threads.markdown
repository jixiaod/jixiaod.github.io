---
layout: post
title: 进程和线程
date: 2017-02-27 11:11:14
categories: Coding

---

[进程](https://zh.wikipedia.org/wiki/行程)（process）是计算机中已运行程序的实体。关于进程需要知道的几点：

* 进程是程序的基本执行实体。
* 在面向线程设计的系统（如当代多数操作系统、Linux 2.6及更新的版本）中，进程本身不是基本运行单位，而是线程的容器。
* 程序本身只是指令、数据及其组织形式的描述，进程才是程序（那些指令和数据）的真正运行实例。
* 若干进程有可能与同一个程序相关系，且每个进程皆可以同步（循序）或异步（平行）的方式独立运行。
* 现代计算机系统可在同一段时间内以进程的形式将多个程序加载到存储器中，并借由时间共享（或称时分复用），以在一个处理器上表现出同时（平行性）运行的感觉。
* 同样的，使用多线程技术（多线程即每一个线程都代表一个进程内的一个独立执行上下文）的操作系统或计算机架构，同样程序的平行线程，可在多CPU主机或网络上真正同时运行（在不同的CPU上）。
* 进程需要一些资源才能完成工作，如CPU使用时间、存储器、文件以及I/O设备，且为依序逐一进行，也就是每个CPU核心任何时间内仅能运行一项进程。
* 进程在运行时，状态（state）会改变。进城的状态包括：
    * 新生（new）：进程新产生中。
    * 运行（running）：正在运行。
    * 等待（waiting）：等待某事发生，例如等待用户输入完成。亦称“阻塞”（blocked）
    * 就绪（ready）：排班中，等待CPU。
    * 结束（terminated）：完成运行。
* 进程间通信（IPC Inter-process communication）:每个进程都有自己的一部分独立的系统资源，彼此是隔离的。为了能使不同的进程互相访问资源并进行协调工作，才有了进程间通信。
* 进程控制块是操作系统能够支持多进程和提供多处理的结构。 
* 当操作系统做进程切换时，它会执行两步操作，一是中断当前处理器中的进程，二是执行下一个进程。 不管是中断还是执行，进程控制块中的程序计数器、上下文数据和进程状态都会发生变化。

在 PHP 中的 [PCNTL](http://php.net/manual/zh/book.pcntl.php) 扩展实现了Unix方式的进程创建，程序执行，信号处理以及进程的中断。但是只能 CLI 环境下使用，且在 Windows 平台不可用。

```php
<?php

$pid = pcntl_fork();
//父进程和子进程都会执行下面代码
if ($pid == -1) {
    //错误处理：创建子进程失败时返回-1.
     die('could not fork');
} else if ($pid) {
     //父进程会得到子进程号，所以这里是父进程执行的逻辑
     pcntl_wait($status); //等待子进程中断，防止子进程成为僵尸进程。
} else {
     //子进程得到的$pid为0, 所以这里是子进程执行的逻辑。
}
```




[线程](https://zh.wikipedia.org/wiki/线程)（thread）是操作系统能够进行运算调度的最小单位。
* 它被包含在进程之中，是进程中的实际运作单位。
* 一条线程指的是进程中一个单一顺序的控制流，一个进程中可以并发多个线程，每条线程并行执行不同的任务。
* 在Unix System V及SunOS中也被称为轻量进程（lightweight processes），但轻量进程更多指内核线程（kernel thread），而把用户线程（user thread）称为线程。
* 线程是独立调度和分派的基本单位。线程可以操作系统内核调度的内核线程，如Win32线程；由用户进程自行调度的用户线程，如Linux平台的POSIX Thread；或者由内核与用户进程，如Windows 7的线程，进行混合调度。
* 同一进程中的多条线程将共享该进程中的全部系统资源，如虚拟地址空间，文件描述符和信号处理等等。但同一进程中的多个线程有各自的调用栈（call stack），自己的寄存器环境（register context），自己的线程本地存储（thread-local storage）。
* 一个进程可以有很多线程，每条线程并行执行不同的任务。
* 线程的四种基本状态：
    * 产生（spawn）
    * 中断（block）
    * 非中断（unblock）
    * 结束（finish）

在PHP中有 [pthreads](http://php.net/manual/zh/intro.pthreads.php) 多线程扩展，实现了面向对象的 多线程 API。可以创建、读取、写入以及执行多线程应用，并可以在多个线程之间进行同步控制。

```php
<?php

class workerThread extends Thread {
    public function __construct($num){
        $this->num = $num;
    }

    public function run(){
        while(true){
            echo $this->num . "\n";
            sleep(1);
        }
    }
}

for ($i=0; $i < 50; $i++){
    $workers[$i] = new workerThread($i);
    $workers[$i]->start();
}
```

线程较之进程，其优势在于一个快，不管是创建新的线程还是终止一个线程；或者是线程间的切换还是线程间共享数据或通信，其速度与进程相比都有较大的优势。进程和线程区别：

* 线程是在一个进程内的，可以共享内存变量实现线程间通信。
    * 而进程间通信是要借助于[进程间通信（IPC）](https://zh.wikipedia.org/wiki/行程間通訊)，文件、管道、消息队列等等。
* 线程比进程更轻量级，开大量进程会比线程消耗更多系统资源。
    * 比如 PHP-FPM 模块。通常情况下，一个PHP-FPM 进程占用的内存为10M左右，假如支持10000并发，就需要100G的内存。一台物理机的资源是有限的，就那么多CPU和内存，决定了单独依靠 PHP-FPM 不可能开发出单机百万级并发的系统。

我们用多进程和多线程的很大因素是为了解决并发问题，先理清一个概念并发和并行是不是一个意思？

 >并发和并行的区别就是一个处理器同时处理多个任务和多个处理器或者是多核的处理器同时处理多个不同的任务。 前者是逻辑上的同时发生（simultaneous），而后者是物理上的同时发生。

由于进程的性能问题，我们觉得并发使用的更多的线程，而不是进程。在处理网络请求时，多线程模型下，可以采用一个独立线程接受请求然后派发到各个 worker 线程的方式。但是使用多线程也存在一些问题：

* 线程读写变量存在同步问题，需要加锁
* 锁的粒度过大会有性能问题，可能会导致只有1个线程在运行，其他线程都在等待锁。这样就不是并行了
* 同时使用多个锁，逻辑复杂，一旦某个锁没被正确释放，可能会发生线程死锁
* 某个线程发生致命错误会导致整个进程崩溃

多进程方式更加稳定，另外利用进程间通信（IPC）也可以实现数据共享。至于为什么进程想对安全稳定，主要是依靠进程[沙箱](https://zh.wikipedia.org/zh-cn/沙盒_(電腦安全))，可以查看这篇文章[《为什么浏览器采用多进程模型》](http://zkread.com/article/584903.html)。

* 共享内存，这种方式和线程间读写变量是一样的，需要加锁，会有同步、死锁问题。
* 消息队列，可以采用多个子进程抢队列模式，性能很好
* PIPE，UnixSock，TCP，UDP。可以使用read/write来传递数据，TCP/UDP方式使用socket来通信，子进程可以分布运行

Swoole 框架的多进程和多线程的设计实用就非常合理，在需要稳定的时候使用进程，在需要效率的时候使用线程。盗个图

![](/images/swoole-process-threads.png)

Swoole 中 worker/task 进程都是由 Manager 进程 Fork 并管理的。

* 子进程结束运行时，Manager 进程负责回收此子进程，避免成为僵尸进程。并创建新的子进程
* 服务器关闭时，Manager 进程将发送信号给所有子进程，通知子进程关闭服务
* 服务器 reload 时，Manager进程会逐个关闭/重启子进程

Swoole 提供了完善的进程管理机制，当Worker进程异常退出，如发生PHP的致命错误、被其他程序误杀，或达到 max_request 次数之后正常退出。主进程会重新拉起新的 Worker 进程。 Worker 进程内可以像普通的 apache+php 或者 php-fpm 中写代码。不需要像 Node.js 那样写异步回调的代码。

Swoole 的Master主进程是一个多线程的程序，其中一组很重要的是Reactor线程。Swoole 在接收到一个请求连接之后，将这个链接分配给一个固定的Reactor线程，并由这个线程来监听socket。在socket可读时读取数据，并进行协议解析，将请求投递到Worker进程。在socket可写时将数据发送给TCP客户端。

