---
layout: post
title: 理解 select、poll 和 epoll
date: 2016-09-25 15:26:48
tags:
categories: Coding

---

select、poll 和 epoll 都是 Linux API 提供的 IO 复用方式。*IO多路复用是指内核一旦发现进程指定的一个或者多个IO条件准备读取，它就通知该进程。*[知乎上的回答](http://www.zhihu.com/question/32163005/answer/55772739) 非常好的解释了什么事IO多路复用，用机场航班调度问题的解释的非常清晰，看完之后豁然开朗。

select、poll 和 epoll 都是阻塞的，用 select 来举例，写法大概是这样：

```c
while true {
    select(fds[])
    for i in fds[] {
        if i has data // 事件是否就绪
            read until unavailable
    }
}
```

上面的代码在执行到 select 时，会阻塞整个程序执行，直到有就绪的描述符才会返回，从而继续向下执行程序。现在如果把上面为代码中的 select 那一行删除，那么程序就会一直循环确认程序中是否准备好的文件描述符。这样在高程序在大量并发连接中只有少量活跃的情况下的系统，就浪费了非常多的CPU资源。现在通过IO复用，在没有就绪的描述符准备好时，就暂时将程序阻塞，从而提高了CPU的利用率。

但是 select 的返回时，我们仅仅是知道有IO事件发生，但并不知道是那个或那几个事件准备好了？于是我们只能轮询所有的描述符，查找到具体就绪可以操作的描述符，然后再进行操作处理。

>传统的 select/poll 另一个致命弱点就是当你拥有一个很大的 socket 集合，不过由于网络延时，任一时间只有部分的 socket 是“活跃”的，但是 select/poll 每次调用都会线性扫描全部的集合，导致效率呈现线性下降。但是epoll不存在这个问题，它只会对“活跃”的 socket 进行操作 — 这是因为在内核实现中 epoll 是根据每个 fd 上面的 callback 函数实现的。那么，只有“活跃”的 socket 才会主动的去调用 callback 函数，其他 idle 状态 socket 则不会，在这点上，epoll 实现了一个“伪”AIO，因为这时候推动力在 OS 内核。

epoll 可以理解为 event poll，基于事件驱动。`epoll_ctl`注册事件并注册 `callback` 回调函数，`epoll_wait`只返回发生的事件。不同于 select 和 poll，把哪个描述符发生了怎样的 IO 事件返回，这样就避免了像 select/poll 对所有的事件的轮询操作。复杂度降低到了O(1)。epoll 的伪代码如下：

```c
while true {
    ready_events[] = epoll_wait(epollfd)
    for i in ready_events[] {
        read or write till
    }
}
```

>epoll是Linux内核为处理大批量文件描述符而作了改进的poll，是Linux下多路复用IO接口select/poll的增强版本，它能显著提高程序在大量并发连接中只有少量活跃的情况下的系统CPU利用率。另一点原因就是获取事件的时候，它无须遍历整个被侦听的描述符集，只要遍历那些被内核IO事件异步唤醒而加入Ready队列的描述符集合就行了。epoll除了提供select/poll那种IO事件的水平触发（Level Triggered）外，还提供了边缘触发（Edge Triggered），这就使得用户空间程序有可能缓存IO状态，减少epoll_wait/epoll_pwait的调用，提高应用程序效率。

使用 epoll 的优点有：

使用 epoll 的优点有：

- select 最不能忍受的是一个进程所打开的FD是有一定限制的，由 FD_SETSIZE 设置，默认是 1024。这对于连接数量比较大的服务器来说根本不能满足。虽然也可以选择多进程的解决方案( Apache 就是这样实现的)，不过虽然 linux 上面创建进程的代价比较小，但仍旧是不可忽视的，加上进程间数据同步远比不上线程间同步的高效，所以也不是一种完美的方案。不过 epoll 没有这个限制，监视的描述符数量不受限制，它所支持的 fd 上限是最大可以打开文件的数目，这个数字一般远大于 2048,举个例子,在 1GB 内存的机器上大约是 10 万左右，具体数目可以 cat /proc/sys/fs/file-max 察看,一般来说这个数目和系统内存关系很大。
- IO 的效率不会随着监视 fd 的数量的增长而下降。epoll 不同于 select 和 poll 轮询的方式，而是通过每个 fd 定义的回调函数来实现的。只有就绪的 fd 才会执行回调函数。
- epoll除了提供select/poll那种IO事件的水平触发（Level Triggered）外，还提供了边缘触发（Edge Triggered），这就使得用户空间程序有可能缓存IO状态，减少epoll_wait/epoll_pwait的调用，提高应用程序效率。
    - 水平触发模式，文件描述符状态发生变化后，如果没有采取行动，它将后面反复通知，这种情况下编程相对简单，libevent 等开源库很多都是使用的这种模式。
    - 边沿触发模式，只告诉进程哪些文件描述符刚刚变为就绪状态，只说一遍，如果没有采取行动，那么它将不会再次告知。理论上边缘触发的性能要更高一些，但是代码实现相当复杂（Nginx 使用的边缘触发）。
- mmap 加速内核与用户空间的信息传递。无论是 select，poll 还是 epoll 都需要内核把FD消息通知给用户空间，如何避免不必要的内存拷贝就很重要，在这点上，epoll 是通过内核与用户空间 mmap 同一块内存实现的。而如果你像我一样从2.5内核就关注 epoll 的话，一定不会忘记手工 mmap 这一步的。

最后，自己之前理解的 Nginx 中只支持 epoll也是不对的。Nginx 封装了很多事件方法，epoll 只是其支持的一种方式，在linux系统中应用最广。还支持select、poll、kqueue等方式，在配置文件中也可以配置处理请求的方式选择哪种，见[Connection processing methods](http://nginx.org/en/docs/events.html)

epoll 仅是在 linux 下支持 IO 复用技术，比如我的 Mac OS 的Unix 系统就不支持epoll。Windows下 IOCP 和 BSD 的 kqueue。Libevent 将不同平台的 IO 复用技术封装统一的接口，使程序可以跨平台。


