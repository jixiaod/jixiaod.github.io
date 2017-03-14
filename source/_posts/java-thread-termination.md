---
title: Java 线程终止问题
tags:
    - Java
    - 线程
categories:
    - Java
date: 2009-07-11 10:25:02
---

对于线程的终止或者中断，由于java中Thread.stop方法已经被弃用，如何终止一个线程，成为了一个挑战，不仅仅要考虑终止的条件也要考虑终止后的收尾工作。
大部分情况下，我们可以通过自己设置的标识例如m_stop布尔变量来，这样写run方法
```
public run ()
{
    while(!m_stop)
    {
        //add your works here.
    }
}
```
然后可以自己写一个Stop方法在里面将m_stop改变，就可以达到终止线程的目的。
但是如果在你的线程中，就是while循环中出现阻塞（大部分情况是wait，sleep或者IO阻塞等等），线程就停在里面，我们就无法通过判断m_stop的值来终止线程了。
这样我们可以通过另一种方式，调用interrupt（）方法，这个方法是比较特别的，
通过测试，interrupt方法实现了这样的功能：
如果线程当前在sleep和wait状态下,会清除interrupt status, 并同时抛出异常.
而在非sleep和wait状态下,就会表明自己为interrupt status.
我们可以通过isInterrupted方法获得interrupt status。
也就是说如果线程处于阻塞状态，而且我们改变m_stop的值已经不起作用的时候，我们可以通过异常来终止线程。也就是在Stop方法里调用interrupt（）方法，如果线程当前处于阻塞状态会产生一个异常。

例如：
```
public void run() {
    while ( !m_stop) {
        System.out.println( "Thread running..." );
        try {
            Thread.sleep( 1000 );
        } catch ( InterruptedException e ) {
            System.out.println( "Thread interrupted..." );
        }
    }   
    System.out.println( "Thread exiting under request..." );
}
```

这样可以通过catch子句跳出run方法，从而终止线程。

总结：
终止线程的方法
1、通过标识设置，跳出while循环
2、通过异常跳出run方法。

