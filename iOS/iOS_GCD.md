# GCD技术

- 任务和队列

  - 任务
    - 同步和异步任务
      - 同步任务
        - 同步执行不具备开启新线程的能力
        - 所以即使是并发队列 在同步执行的前提下也会变成串行
      - 异步任务
        - 异步执行允许开启新的线程
  - 队列
    - 并发和串行队列
      - 串行队列：GCD默认提供了“主队列”（一个默认存在的，执行在主线程中的串行队列。默认情况下代码都是在主队列中执行）
      - 并发队列：GCD默认提供一个全局并发队列

- 任务创建

  - GCD允许程序员通过代码块来创建多线程的任务，而无需编写多线程代码并对线程进行直接的管理

- 任务和队列类型的组合

  - 任务有同步和异步，队列有串行和并发队列，组合起来就有4种不同的场景
    - 同步执行+并发队列：
      - 这种场景下虽然是并发队列，但是由于任务是同步执行的，所以依然还是单线程执行，所以最终的结果是串行执行
    - 同步执行+串行队列：
      - 这个没啥好说的 肯定是串行
    - 异步执行+并发队列
      - 多线程并发执行任务
    - 异步执行+串行队列
      - 另一条线程（区别于主线程）串行执行任务
    - 同步执行+主队列
      - 这会导致死锁，因为程序默认运行在主队列，新创建的任务会和主程序形成循环等待。

- GCD线程通信

  - 在线程之间切换
  - 只需要在dispatch之间嵌套其他队列的任务

- GCD栅栏方法

  - 使用场景：有的时候我们有两组需要分别异步执行的操作，但是组间是有序的，也就是一组操作全执行完才执行下一组，这个时候栅栏方法就可以将这两组异步操作隔开
  - dispatch_barrier_async 方法会等待前边追加到并发队列中的任务全部执行完毕之后，再将指定的任务追加到该异步队列中。

- dispatch_once（单次执行）

  - 【应用】可以用于创建单例，在程序第一次执行时创建唯一的单例
  - once_token是静态的，否则可能会产生各种错误

- dispatch_apply（快速迭代）

- dispatch_once源码理解

- Semaphore信号量

- GCD知识图谱

  ![img](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggmxzjb1mwj30u00uh7wj.jpg)



在自己学习和尝试使用GCD的过程中，我发现了一些问题，同时对dispatch_once产生了兴趣，想要仔细看一下源码了解一下，最终我对这一部分的总结和学习笔记整理如下：

先上dispatch_once的源码：

```objective-c
#include "internal.h"

#undef dispatch_once
#undef dispatch_once_f

//请求链表的节点 结构体
struct _dispatch_once_waiter_s {
    volatile struct _dispatch_once_waiter_s *volatile dow_next;
    _dispatch_thread_semaphore_t dow_sema;
};

#define DISPATCH_ONCE_DONE ((struct _dispatch_once_waiter_s *)~0l)

#ifdef __BLOCKS__
// 应用程序调用的入口
void
dispatch_once(dispatch_once_t *val, dispatch_block_t block)
{
    struct Block_basic *bb = (void *)block;
  	// 关键步骤 内部逻辑
    dispatch_once_f(val, block, (void *)bb->Block_invoke);
}
#endif

DISPATCH_NOINLINE
void
dispatch_once_f(dispatch_once_t *val, void *ctxt, dispatch_function_t func)
{
    struct _dispatch_once_waiter_s * volatile *vval =
            (struct _dispatch_once_waiter_s**)val;

    // 地址类似于简单的哨兵位
    struct _dispatch_once_waiter_s dow = { NULL, 0 };

    // 在Dispatch_Once的block执行期进入的dispatch_once_t更改请求的链表
    struct _dispatch_once_waiter_s *tail, *tmp;

    // 局部变量，用于在遍历链表过程中获取每一个在链表上的更改请求的信号量
    _dispatch_thread_semaphore_t sema;

    // Compare and Swap（用于首次更改请求）
    if (dispatch_atomic_cmpxchg(vval, NULL, &dow)) {
        dispatch_atomic_acquire_barrier();

        // 调用dispatch_once的block
        _dispatch_client_callout(ctxt, func);

        dispatch_atomic_maximally_synchronizing_barrier();
        //dispatch_atomic_release_barrier(); // assumed contained in above

        // 更改请求成为DISPATCH_ONCE_DONE(原子性的操作)
        tmp = dispatch_atomic_xchg(vval, DISPATCH_ONCE_DONE);
        tail = &dow;

        // 发现还有更改请求，继续遍历
        while (tail != tmp) {

            // 如果这个时候tmp的next指针还没更新完毕，等一会
            while (!tmp->dow_next) {
                _dispatch_hardware_pause();
            }

            // 取出当前的信号量，告诉等待者，我这次更改请求完成了，轮到下一个了
            sema = tmp->dow_sema;
            tmp = (struct _dispatch_once_waiter_s*)tmp->dow_next;
            _dispatch_thread_semaphore_signal(sema);
        }
    } else {
        // 非首次请求，进入这个逻辑块
        dow.dow_sema = _dispatch_get_thread_semaphore();
        for (;;) {
            // 遍历每一个后续请求，如果状态已经是Done，直接进行下一个
            // 同时该状态检测还用于避免在后续wait之前，信号量已经发出(signal)造成
            // 的死锁
            tmp = *vval;
            if (tmp == DISPATCH_ONCE_DONE) {
                break;
            }
            dispatch_atomic_store_barrier();
            // 如果当前dispatch_once执行的block没有结束，那么就将这些
            // 后续请求添加到链表当中
            if (dispatch_atomic_cmpxchg(vval, tmp, &dow)) {
                dow.dow_next = tmp;
                _dispatch_thread_semaphore_wait(dow.dow_sema);
            }
        }
        _dispatch_put_thread_semaphore(dow.dow_sema);
    }
}
```

从上述代码可以看出，**dispatch_once并非只执行一次那么简单**，它维护一个请求等待者的链表，接受多次请求。

当执行block期间有其他的请求进入block（单例模式），**这个时候就会引发循环等待，导致死锁。**

在工程实践当中其实应当避免**过度依赖单例**，使用单例的过程中需要注意互相调用的问题，比如A->B, B->A，但是一般来说这种属于低级错误，但是有的时候不可避免地会出现一些层级更多的相互调用（例如A->C->B->A）这个时候就需要更加注意了。

我认为单例其实本质上类似于全局变量，过度的使用会对程序的稳定性造成威胁。

