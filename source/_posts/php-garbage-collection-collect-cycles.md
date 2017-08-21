---
title: PHP 的垃圾回收机制－理解PHP如何解决循环引用导致的内存泄漏问题
date: 2017-04-07 16:00:53
tags:
    - PHP
    - PHP7
    - GC
    - 源码阅读
categories:
    - PHP
---

##### 先来看一下什么是循环引用问题？

在 PHP 5.2 中使用的垃圾回收算法是 Reference Counting（引用计数）。非常简单，为每个 zval 分配一个计数器，当一个 zval 建立时计数器初始化为1，以后每有一个新变量引用此 zval，则计数器加1，而每当减少一个引用的变量则计数器减 1，当垃圾回收机制运作的时候，将所有计数器为0的zval销毁并回收其占用的内存。但是对于以下代码，把数组作为一个元素添加到自己，自身引用自身。

```php
<?php
$a = array( 'one' );
$a[] =& $a;
xdebug_debug_zval( 'a' );
?>

// output 
a: (refcount=2, is_ref=1)=array (
   0 => (refcount=1, is_ref=0)='one',
   1 => (refcount=2, is_ref=1)=...
)
```

![](/images/php/loop-array.png)
能看到数组变量 `a` 同时也是这个数组的第二个元素`1` 指向的变量容器中 `refcount` 为 2。上面的输出结果中的"..."说明发生了递归操作， 显然在这种情况下"..."表示指向原始数组。

跟刚刚一样，对一个变量调用 unset，将从符号表中删除这个引用，且它指向的 zval 的引用次数也减 1。所以，如果我们在执行完上面的代码后，对变量 `$a` 调用 unset， 那么变量 `$a` 和数组元素 `1` 所指向的变量容器的引用次数减 1，变成 1。

```php
// output
(refcount=1, is_ref=1)=array (
   0 => (refcount=1, is_ref=0)='one',
   1 => (refcount=1, is_ref=1)=...
)
```

![](/images/php/leak-array.png)

尽管不再有任何作用域中的**任何**符号表中的引用指向这个 zval，由于数组元素 `1` 仍然指向数组本身，所以这个 zval 不能被清除 。因为没有另外的符号指向它，所以没有办法清除这个结构，结果就会导致内存泄漏。

这就是循环引用，虽然 PHP 将在脚本执行结束时会清除这个数据结构，但是在 PHP 清除之前，将耗费不少内存。这中问题如果出现很难被发现。仅仅一两次倒没什么，但是如果出现几千次，甚至几十万次的内存泄漏，这显然是个大问题。尤其是当PHP被作为守护进程，长时间运行时。

##### 那么PHP是如何解决的呢？

PHP 5.3 的垃圾回收算法仍然以引用计数为基础，但是不再使用简单计数，而是使用了同步回收算法，这个算法由IBM的工程师在论文 Concurrent Cycle Collection in Reference Counted Systems 中提出，包括Java的垃圾回收机制中也有在使用该算法。

下面我们来看看PHP的实现。猜测对象回收时应该会有垃圾回收调用，所以找到Object对象释放的函数。 在 Zend/zend_objects_API.h `zend_object_release` 函数中

```php
static zend_always_inline void zend_object_release(zend_object *obj)
{
    if (--GC_REFCOUNT(obj) == 0) {
        zend_objects_store_del(obj);
    } else if (UNEXPECTED(GC_MAY_LEAK((zend_refcounted*)obj))) {
        gc_possible_root((zend_refcounted*)obj);
    }   
}

```

当一个对象被释放时（调用 `zend_object_release` 函数），根据简单的引用计数原则，如果引用计数减少到 0，所在变量容器将被清除（free）。否则引用计数减少到非 0 值时，会产生垃圾周期（即调用 `gc_possible_root` 函数）。这个函数的名字有点奇怪，possible root 可能根？看一下 `gc_possible_root` 函数内容，在 Zend/zend_gc.c 中 `gc_possible_root`。

```php
ZEND_API void ZEND_FASTCALL gc_possible_root(zend_refcounted *ref)
{
    gc_root_buffer *newRoot;
    newRoot = GC_G(unused);

   // ....... 省略部分代码

    GC_TRACE_SET_COLOR(ref, GC_PURPLE);
    GC_INFO(ref) = (newRoot - GC_G(buf)) | GC_PURPLE;
    newRoot->ref = ref;

    newRoot->next = GC_G(roots).next;
    newRoot->prev = &GC_G(roots);
    GC_G(roots).next->prev = newRoot;
    GC_G(roots).next = newRoot;
    // ....
}
```

这个函数把可能根（possible roots）放在了 `GC_G(roots)` 中，这个 `GC_G(roots)` 是一个双向链表。结构如下：

```php
typedef struct _gc_root_buffer {
    zend_refcounted          *ref;
    struct _gc_root_buffer   *next;     /* double-linked list               */
    struct _gc_root_buffer   *prev;
    uint32_t                 refcount;
} gc_root_buffer;
```
并且这个链表的长度是定义是 `#define GC_ROOT_BUFFER_MAX_ENTRIES 10001`。猜测简单解决循环引用原理：因为已经没有任何符号指向循环引用指向的zval，于是用这个*可能根双向链表*来记录可能产生内存泄漏的结构体。

接着往下看代码， `GC_TRACE_SET_COLOR(ref, GC_PURPLE);` 设置颜色为紫色，关于颜色的定义可以在代码注释中看到：

```php
/**
* Colors and its meaning
* ----------------------
*
* BLACK  (GC_BLACK)   - In use or free. 
* GREY   (GC_GREY)    - Possible member of cycle.
* WHITE  (GC_WHITE)   - Member of garbage cycle.
* PURPLE (GC_PURPLE)  - Possible root of cycle.
*
```

紫色表示*疑似垃圾（Possible root of cycle）*。我们可以推测 PHP 把可能存在内存泄露的引用存放到 Possible roots 里，这样在清理垃圾时，就避免不得不检查所有引用计数。

现在有了垃圾回收的*疑似垃圾*的一个链表。那么是在何时清除这些垃圾呢？

回看 `gc_possible_root` 函数中，调用了 `gc_collect_cycles` ，这个函数其实就是 `zend_gc_collect_cycles`，在 Zend/zend.c 的 `zend_startup`中定义实现。

```php
     /* Set up the default garbage collection implementation. */
     gc_collect_cycles = zend_gc_collect_cycles;
```

在来看`gc_collect_cycles`的调用条件，在Zend/zend_gc.c 中 `gc_possible_root`中

```php
// 略...
    newRoot = GC_G(unused);
    if (newRoot) {
        GC_G(unused) = newRoot->prev;
    } else if (GC_G(first_unused) != GC_G(last_unused)) {
        newRoot = GC_G(first_unused);
        GC_G(first_unused)++;
    } else {
        if (!GC_G(gc_enabled)) {
            return;
        }    
        GC_REFCOUNT(ref)++;
        gc_collect_cycles();
        GC_REFCOUNT(ref)--;
        if (UNEXPECTED(GC_REFCOUNT(ref)) == 0) {
            zval_dtor_func(ref);
            return;
        }    
        if (UNEXPECTED(GC_INFO(ref))) {
            return;
        }    
        newRoot = GC_G(unused);
        if (!newRoot) {
#if ZEND_GC_DEBUG
            if (!GC_G(gc_full)) {
                fprintf(stderr, "GC: no space to record new root candidate\n");
                GC_G(gc_full) = 1;
            }    
#endif
            return;
        }    
        GC_G(unused) = newRoot->prev;
    }
// 略...
```

看下上面的 if else 在什么条件下能被执行到。`unused`、`first_unused`、`last_unused`在`_zend_gc_globals`中。

```php
typedef struct _zend_gc_globals {
  // ...
    gc_root_buffer   *buf;              /* preallocated arrays of buffers   */
    gc_root_buffer    roots;            /* list of possible roots of cycles */
    gc_root_buffer   *unused;           /* list of unused buffers           */
    gc_root_buffer   *first_unused;     /* pointer to first unused buffer   */
    gc_root_buffer   *last_unused;      /* pointer to last unused buffer    */

  // ...
} zend_gc_globals;
```
于是可以得出结论，仅仅在根缓冲区满了时（也就是`GC_ROOT_BUFFER_MAX_ENTRIES` 不够时），才对缓冲区内部所有不同的变量容器执行垃圾回收操作。

那么是如何进行垃圾回收的呢？看 `zend_gc_collect_cycles` 函数就好了。在注释中也有描述

```php

 * Flow
* =====
*
* The garbage collect cycle starts from 'gc_mark_roots', which traverses the
* possible roots, and calls mark_grey for roots are marked purple with
* depth-first traverse.
*
* After all possible roots are traversed and marked,
* gc_scan_roots will be called, and each root will be called with
* gc_scan(root->ref)
*
* gc_scan checkes the colors of possible members.
*
* If the node is marked as grey and the refcount > 0
*    gc_scan_black will be called on that node to scan it's subgraph.
* otherwise (refcount == 0), it marks the node white.
*
* A node MAY be added to possbile roots when ZEND_UNSET_VAR happens or
* zend_assign_to_variable is called only when possible garbage node is
* produced.
* gc_possible_root() will be called to add the nodes to possible roots.
*
*
* For objects, we call their get_gc handler (by default 'zend_std_get_gc') to
* get the object properties to scan.
*

```
过程：
1. 垃圾回收周期从 `gc_mark_roots` 函数开始，深度优先遍历所有*可能根*，调用 `mark_grey` 把原标记为紫色（Possible root of cycle）的root标记为灰色（Possible member of cycle）。
2. 当所有的root都被遍历并且标记之后，调用 `gc_scan_roots` ，然后每个root 执行 `gc_scan(root->ref)`。
3. `gc_scan` 检查所有的疑似垃圾成员。
4. 如果节点被标记为灰色，并且 refcount > 0，该节点执行 `gc_scan_black`扫描它的子图。否则（ refcount == 0），标记节点为白色（Member of garbage cycle 垃圾周期）。
5. 最后被标记为白色的节点会被真正的清除。代码就不贴了，都在`zend_gc_collect_cycles`函数中。可以说一下，对于 object 调用的是efree(p)。

##### 总结：
1. PHP的垃圾回收使用的是同步回收算法（Concurrent Cycle Collection in Reference Counted Systems）。
2. 基本原来是通过一个双向链表来存储可能存在内存泄漏的zval引用，解决因为符号表中已经不存在指向zval的引用导致无法删除zval的问题。
3. 当可能存在内存泄漏的引用被释放时，比如 `unset` 一个 Object，就把该引用添加到可能根的链表中。
4. 同时判断可能根链表是否已满，如果已满（也就是`GC_ROOT_BUFFER_MAX_ENTRIES` 不够时），则开启垃圾回收周期。在`shutdown_executor`（脚本执行结束）时，也会开始垃圾回收周期。
5. `zend_gc_collect_cycles` 垃圾回收周期中，深度遍历所有可能根。用 BLACK、GREY、WHITE、PURPLE 来记录回收周期中变量的状态，最终清楚垃圾变量。

##### References：

- 引用计数基本知识 http://php.net/manual/zh/features.gc.refcounting-basics.php
- 回收周期(Collecting Cycles)  http://php.net/manual/zh/features.gc.collecting-cycles.php



