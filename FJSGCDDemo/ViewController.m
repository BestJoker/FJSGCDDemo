//
//  ViewController.m
//  FJSGCDDemo
//
//  Created by 付金诗 on 16/6/15.
//  Copyright © 2016年 www.fujinshi.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"FJSGCDDemo";
    
    /*
     重点：
     1.dispatch_queue_create(生成Dispatch Queue)
     2.Main Dispatch Queue/Global Dispatch Queue
     3.dispatch_set_target_queue
     4.dispatch_after
     5.Dispatch Group
     6.dispatch_barrier_async
     7.dispatch_sync
     8.dispatch_apply
     9.dispatch_suspend/dispatch_resume
     10.Dispatch Semaphore
     11.dispatch_once
     12.Dispatch I/O
     13.spatch_set_context与dispatch_set_finalizer_f
     */
    
#pragma mark -- 1.dispatch_queue_create(生成Dispatch Queue)
    /*
     1.Dispatch_Queue
     两种：    
     Serial Dispatch Queue   串行队列 顺序执行
     Concurrent Dispatch Queue 并行队列 并行执行
     dispatch_async(dispatch_queue_t queue>, ^(void)block)
     */
#pragma mark --  2.Main Dispatch Queue/Global Dispatch Queue
    /*
     2.Dispatch_queue_creat(生成Dispatch Queue)
     生成Serial Queue串行 但将4个它可并行实施多线程更新数据 每一个Searial Queue一个线程
     1).生成Serial Queue
     dispatch_queue_t queue = dispatch_queue_create("name", NULL);
     2).生成Concurrent Queue
     dispatch_queue_t queue = dispatch_queue_create("name", DISPATCH_QUEUE_CONCURRENT);
     
     create 对应 release （MRC）
     dispatch_release(queue);
     */
    [self mainDispatchQueueAndGlobalDispatchQueue];
    
#pragma mark --  3.dispatch_set_target_queue
    
    [self dispatchSetTargetQueue];
    
#pragma mark --  4.dispatch_after
    [self dispatchAfter];
    
#pragma mark --  5.Dispatch Group
    [self dispatchGroup];
    
#pragma mark --  6.dispatch_barrier_async
    [self dispatchBarrierAsync];
    
#pragma mark --  7.dispatch_sync
    [self dispatchSync];
    
#pragma mark --  8.dispatch_apply
    [self dispatchApply];
    
#pragma mark --  9.dispatch_suspend/dispatch_resume
    [self dispatchSuspendAndResume];
    
#pragma mark --  10.Dispatch Semaphore
    [self dispatchSemaphore];
    
#pragma mark --  11.dispatch_once
    //dispatch_once_t必须是全局或static变量
    //这一条算是“老生常谈”了，但我认为还是有必要强调一次，毕竟非全局或非static的dispatch_once_t变量在使用时会导致非常不好排查的bug，正确的如下：
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
             // 初始化,一般用于单例中
    });
    
#pragma mark --  12.Dispatch I/O
    //将文件分割成一块一块进行读取
    
#pragma mark --  13.spatch_set_context与dispatch_set_finalizer_f

    
    
}



#pragma mark --  2.Main Dispatch Queue/Global Dispatch Queue
- (void)mainDispatchQueueAndGlobalDispatchQueue
{
    //1).生成Serial Queue
    dispatch_queue_t serialQueue = dispatch_queue_create("一个标识,类似于一个名字", NULL);
    //2).生成Concurrent Queue
    dispatch_queue_t concurrent = dispatch_queue_create("并行队列", NULL);
}


#pragma mark --  3.dispatch_set_target_queue
- (void)dispatchSetTargetQueue
{
    //3.Main Dispatch Queue (串行)/ Global Dispatch Queue(并行) -- (系统的)
    //1).Main Dispatch Queue 系统的主线程,串行线程
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    //2).Global Dispatch Queue(四种优先级) 不需要retain release
    //(1)High Priority
    dispatch_queue_t highQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    //(2)Default Priority
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //(3)Low Priority
    dispatch_queue_t lowQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    //(4)Background Priority
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    //在Main Dispatch Queue和Global Dispatch Queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 可并行执行处理
        // 在Main Dispatch Queue中执行Block
        dispatch_async(dispatch_get_main_queue(), ^{
            // 主线程中执行处理
        });
    });
    //数据的处理都放到并行线程中,对于UI的修改,要放到主线程中.
    
    
    //4.dispatch_set_target_queue(变更生成的Dispatch Queue优先级)
    dispatch_queue_t queue = dispatch_queue_create("name", NULL);
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    // 使生成的queue优先级与globalQueue相同
    dispatch_set_target_queue(queue, globalQueue);
    //层次管理
    //Dispatch Queue 如果多个Serial Dispatch Queue使用该函数指定为目标为某一个Serial Dispatch Queue
}
#pragma mark --  4.dispatch_after

- (void)dispatchAfter
{
    //dispatch_after:是延迟提交，不是延迟运行, 同时并不精确
    //官方文档说明:Enqueue a block for execution at the specified time.
    //Enqueue，就是入队，指的就是将一个Block在特定的延时以后，加入到指定的队列中，不是在特定的时间后立即运行！。
    //方法一
    /*
     #define NSEC_PER_SEC 1000000000ull
     
     #define USEC_PER_SEC 1000000ull
     
     #define NSEC_PER_USEC 1000ull
     
     - NSEC_PER_SEC，每秒有多少纳秒。
     
     - USEC_PER_SEC，每秒有多少毫秒。（注意是指在纳秒的基础上）
     
     - NSEC_PER_USEC，每毫秒有多少纳秒。
     
     关键词解释：
     
     - NSEC：纳秒。
     
     - USEC：微妙。
     
     - SEC：秒
     
     - PER：每
     */
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3ull * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"处理事情");
    });
    //方法二
    /*
     dispatch_after 并不是在指定时间后执行处理，而是在指定质检追加处理到Dispatch Queue于3秒后执行，dispatch_async()函数追到Block到Main Dispatch Queue
     参数1：dispatch_time类型，使用dispatch_time函数和dispatch_walltime函数生成,dispatch_time类型值中指定的时间开始；dispatch_walltime计算绝对时间（固定时间）
     参数2：指定要追加处理Dispatch Queue
     参数3：指定要记述执行处理的Block
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"处理事情");
    });
    //注意:
    //创建串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_SERIAL);
    //立即打印一条信息
    NSLog(@"开始添加block");
    
    //提交一个block
    dispatch_async(serialQueue, ^{
        //让线程沉睡10s
        [NSThread sleepForTimeInterval:10];
        NSLog(@"第一个block完成");
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)),serialQueue, ^{
        NSLog(@"Afterblock完成");
    });
    
    /*
     结果是: 开始添加block ->  第一个block完成 ->  Afterblock完成
     从结果也验证了，dispatch_after只是延时提交block，并不是延时后立即执行。所以想用dispatch_after精确控制运行状态的朋友可要注意了~
     */
    
}

#pragma mark --  5.Dispatch Group
- (void)dispatchGroup
{
    //5.Dispatch Group:在Dispatch Queue全部结束后想执行结束处理
    //1) 三个事件异步执行,done在三个事件都完成之后,才会调用.
    dispatch_group_t groupQueue = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_group_async(groupQueue, queue, ^{
        NSLog(@"1");
    });
    dispatch_group_async(groupQueue, queue, ^{
        NSLog(@"2");
    });
    dispatch_group_async(groupQueue, queue, ^{
        NSLog(@"3");
    });
    dispatch_group_notify(groupQueue, dispatch_get_main_queue(), ^{
        NSLog(@"done");
    });
    
    //2)等待其中并行处理多长时间之后,就执行
    dispatch_group_t groupQueueTwo = dispatch_group_create();
    dispatch_queue_t queueTwo = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_group_async(groupQueueTwo, queueTwo, ^{
        NSLog(@"4");
    });
    dispatch_group_async(groupQueueTwo, queueTwo, ^{
        NSLog(@"5");
    });
    dispatch_group_async(groupQueueTwo, queueTwo, ^{
        NSLog(@"6");
    });
    
    //第二个参数指定为等待时间（超时）dispatch_time_t类型的值，上面用的是一直等待。
    dispatch_group_wait(groupQueueTwo, DISPATCH_TIME_FOREVER);
    
    dispatch_time_t queueTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
    
    long result = dispatch_group_wait(groupQueueTwo, queueTime);
    if (!result) {
        NSLog(@"属于Dispatch Group全部处理执行结束");
    }else
    {
        NSLog(@"属于Dispatch Group的某一个处理还在执行");
    }
    /*
    不为0意味着虽然过了指定时间，但属于Dispatch Group的某一个处理还在执行中，为0全部处理执行结束
    指定DISPATCH_TIME_NOW,则不用任何等待即可判定属于Dispatch Group的处理是否结束，long result = dispatch_group_wait(group, DISPATCH_TIME_NOW);
    当你无法直接使用队列变量时，就无法使用dispatch_group_async了,也可以使用dispatch_group_enter和dispatch_group_leave来作为判断group结束的标志，下面以使用AFNetworking时的情况：
     
     同时处理多个网络请求,要求在所有请求都结束的时候,刷新UI,使用dispatch_group_enter，dispatch_group_leave就可以方便的将一系列网络请求“打包”起来~
     
     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
     
     //Enter group
     
     dispatch_group_enter(group);
     
     [manager GET:@"http://www.baidu.com" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
     
     //Deal with result...
     
     //Leave group
     
     dispatch_group_leave(group);
     
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
     //Deal with error...
     
     //Leave group
     
     dispatch_group_leave(group);
     
     }];
     
     //More request...
     
     dispatch_group_notify(group, dispatch_get_main_queue(), ^{
     更新UI
     });
     

    */
}

#pragma mark --  6.dispatch_barrier_async

- (void)dispatchBarrierAsync
{
    //6.dispatch_barrier_async:用来加锁，防止数据源冲突
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        NSLog(@"11");
    });
    dispatch_async(queue, ^{
        NSLog(@"12");
    });
    dispatch_async(queue, ^{
        NSLog(@"13");
    });
    
    //执行barrier完成之后才继续执行
    dispatch_barrier_async(queue, ^{
        NSLog(@"barrier done");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"14");
    });
    
    /*
     dispatch_barrier_async的作用就是向某个队列插入一个block，当目前正在执行的block运行完成后，阻塞这个block后面添加的block，只运行这个block直到完成，然后再继续后续的任务，有点“唯我独尊”的感觉=。=
     
     值得注意的是：
     
     dispatchbarrier\(a)sync只在自己创建的并发队列上有效，在全局(Global)并发队列、串行队列上，效果跟dispatch_(a)sync效果一样。
     
     既然在串行队列上跟dispatch_(a)sync效果一样，那就要小心别死锁！
     dispatch_barrier_sync(dispatch_get_main_queue(), ^{
     NSLog(@"我是死锁");
     });
     */
    
}

#pragma mark --  7.dispatch_sync

- (void)dispatchSync
{
    //7.dispatch_sync:同步（将Block同步到Dispatch Queue）中，在追加Block结束之前，dispatch_sync会一直等待（当前线程提醒）
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    // 处理结束前不会返回
    dispatch_sync(queue, ^{
        NSLog(@"done");
    });
    
    //dispatch_sync导致的死锁
    //涉及到多线程的时候，不可避免的就会有“死锁”这个问题，在使用GCD时，往往一不小心，就可能造成死锁，看看下面的“死锁”例子：
    /*
    //在main线程使用“同步”方法提交Block，必定会死锁。
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        NSLog(@"I am block...");
        
    });
    */
    
}



#pragma mark --  8.dispatch_apply

- (void)dispatchApply
{
    //8.dispatch_apply:等待处理结果执行完才进行,关联dispatch_sync函数和Dispatch Group的关联API
    /*
     第一个参数为重复次数
     第二个参数为追加对象的Dispatch Queue
     第三个参数为追加处理 带参数Block，为了区别重复Block
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"%zu",index);
    });
    //明明是提交到异步的队列去运行，但是“After apply”居然在apply后打印，也就是说，dispatch_apply将外面的线程（main线程）“阻塞”了！
    //查看官方文档，dispatch_apply确实会“等待”其所有的循环运行完毕才往下执行=。=，看来要小心使用了。
    /*
     //在apply中使用主线程,会产生相互等待的死锁
         dispatch_apply(10, dispatch_get_main_queue(), ^(size_t index) {
            NSLog(@"%zu",index);
        });

     避免dispatch_apply的嵌套调用,否则也会产生死锁.
     dispatch_queue_t queue = dispatch_queue_create("me.tutuge.test.gcd", DISPATCH_QUEUE_SERIAL);
     
     dispatch_apply(3, queue, ^(size_t i) {
     
     NSLog(@"apply loop: %zu", i);
     
     //再来一个dispatch_apply！死锁！
     
     dispatch_apply(3, queue, ^(size_t j) {
     
     NSLog(@"apply loop inside %zu", j);
     
     });
     
     });
     */
    NSLog(@"apply完成");
          
}

#pragma mark --  9.dispatch_suspend/dispatch_resume
- (void)dispatchSuspendAndResume
{
    /*
     挂起函数：dispatch_suspend(queue); 被追加到Dispatch Queue中的尚未执行的处理停止
     回复函数：dispatch_resume(queue)p; 继续执行
     
     dispatch_suspend != 立即停止队列的运行
     dispatch_suspend，dispatch_resume提供了“挂起、恢复”队列的功能，简单来说，就是可以暂停、恢复队列上的任务。但是这里的“挂起”，并不能保证可以立即停止队列上正在运行的block，看如下例子：
     */
    dispatch_queue_t queue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    //提交第一个block 延时5s打印
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:5];
        NSLog(@"After 5 seconds...");
    });
    
    //提交第二个block，也是延时5秒打印
    dispatch_async(queue, ^{
        
        [NSThread sleepForTimeInterval:5];
        
        NSLog(@"After 5 seconds again...");
        
    });
    
    //延时一秒
    
    NSLog(@"sleep 1 second...");
    
    [NSThread sleepForTimeInterval:1];
    
    //挂起队列
    
    NSLog(@"suspend...");
    
    dispatch_suspend(queue);
    
    //延时10秒
    
    NSLog(@"sleep 10 second...");
    
    [NSThread sleepForTimeInterval:10];
    
    
    //恢复队列
    
    NSLog(@"resume...");
    
    dispatch_resume(queue);
    
    /*
     2016-06-15 22:30:15.905 FJSGCDDemo[20425:462101] sleep 1 second...
     2016-06-15 22:30:16.906 FJSGCDDemo[20425:462101] suspend...
     2016-06-15 22:30:16.906 FJSGCDDemo[20425:462101] sleep 10 second...
     2016-06-15 22:30:20.907 FJSGCDDemo[20425:462215] After 5 seconds...
     2016-06-15 22:30:26.908 FJSGCDDemo[20425:462101] resume...
     2016-06-15 22:30:31.913 FJSGCDDemo[20425:462143] After 5 seconds again...
     可知，在dispatch_suspend挂起队列后，第一个block还是在运行，并且正常输出。
     
     结合文档，我们可以得知，dispatch_suspend并不会立即暂停正在运行的block，而是在当前block执行完成后，暂停后续的block执行。
     
     所以下次想暂停正在队列上运行的block时，还是不要用dispatch_suspend了吧~
     */
}

#pragma mark --  10.Dispatch Semaphore
- (void)dispatchSemaphore
{
    /*
     10.Dispatch Semaphore:暂停，播放
     持有计数的信号，该计数是多线程中的计数类型信号，信号类似于过马路手旗，可以通过举起手旗，不可通过时放下手旗，计数为0时等待，计数为1或大于1时，减去1而不等待
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    for (NSInteger i = 0; i < 10000; i++) {
        dispatch_async(queue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            // 进行排他处理，计数值+1进行
            if (i == 500) {
                dispatch_semaphore_signal(semaphore);
                NSLog(@"我这个时候才能处理事情");
            }
            NSLog(@"难道我处理不了事情?");
        });
    }
    
}

#pragma mark --  13.dispatch_set_context与dispatch_set_finalizer_f
- (void)dispatchContextAndFinalizer
{
    /*
     dispatch_set_context可以为队列添加上下文数据，但是因为GCD是C语言接口形式的，所以其context参数类型是“void *”。也就是说，我们创建context时有如下几种选择：
     
     用C语言的malloc创建context数据。
     
     用C++的new创建类对象。
     
     用Objective-C的对象，但是要用__bridge等关键字转为Core Foundation对象。
     
     以上所有创建context的方法都有一个必须的要求，就是都要释放内存！，无论是用free、delete还是CF的CFRelease，我们都要确保在队列不用的时候，释放context的内存，否则就会造成内存泄露。
     
     所以，使用dispatch_set_context的时候，最好结合dispatch_set_finalizer_f使用，为队列设置“析构函数”，在这个函数里面释放内存，大致如下：
     
     void cleanStaff(void *context) {
     
     //释放context的内存！
     
     //CFRelease(context);
     
     //free(context);
     
     //delete context;
     
     }
     
     ...
     
     //在队列创建后，设置其“析构函数”
     
     dispatch_set_finalizer_f(queue, cleanStaff);
    */
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
