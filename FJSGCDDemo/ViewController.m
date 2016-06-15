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
    /*
     挂起函数：dispatch_suspend(queue); 被追加到Dispatch Queue中的尚未执行的处理停止
     回复函数：dispatch_resume(queue)p; 继续执行
     */
#pragma mark --  10.Dispatch Semaphore
    [self dispatchSemaphore];
    
#pragma mark --  11.dispatch_once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
             // 初始化,一般用于单例中
    });
    
#pragma mark --  12.Dispatch I/O
    //将文件分割成一块一块进行读取
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
    //dispatch_after:想在3秒后执行（但是并不确定）
    //方法一
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
    //在apply中使用主线程,会产生相互等待的死锁
//    dispatch_apply(10, dispatch_get_main_queue(), ^(size_t index) {
//        NSLog(@"%zu",index);
//    });
    NSLog(@"apply完成");
          
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
