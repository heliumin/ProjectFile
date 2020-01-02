//
//  ViewController.m
//  MultiThread
//
//  Created by 贺刘敏 on 2019/12/31.
//  Copyright © 2019 hlm. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>

@interface ViewController ()

/** 售票员A */
@property (nonatomic, strong) NSThread *threadA;
/** 售票员B */
@property (nonatomic, strong) NSThread *threadB;
/** 售票员C */
@property (nonatomic, strong) NSThread *threadC;

@property (nonatomic, assign) NSInteger totalCount;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.totalCount = 100;
}

- (IBAction)btnAction:(id)sender {
 
//    [self pthreadDemo];
    
//    [self createNSThreadDemo];
    
//    [self threadSafeDemo];

//    [self asyncConcurrent];
    
//    [self asyncSerial];
    
//    [self syncConcurrent];
    
    [self GCDCommunicate];
}
- (IBAction)asyConCurrent:(id)sender {
    
    [self asyncConcurrent];
}
- (IBAction)asySerial:(id)sender {
    
    [self asyncSerial];
}

- (IBAction)syConCurrent:(id)sender {
    
    [self syncConcurrent];
}
- (IBAction)sySerial:(id)sender {
    
    [self syncSerial];
}

- (IBAction)asyMain:(id)sender {
    
    [self asyncMain];
}
- (IBAction)syMain:(id)sender {
    
    [self syncMain];
}

#pragma mark - pthread
- (void)pthreadDemo{
    
    pthread_t hlmThread_t;
    pthread_create(&hlmThread_t, NULL, task, NULL);
}

void *task(void *param){

    NSLog(@"\n%@",[NSThread currentThread]);
    return NULL;
}

#pragma mark - NSThread
- (void)createNSThreadDemo{
    
    NSThread *threadA = [[NSThread alloc]initWithTarget:self selector:@selector(run:) object:@"ABC"];
    //设置属性
    threadA.name = @"线程A";
    //设置优先级  取值范围 0.0 ~ 1.0 之间 最高是1.0 默认优先级是0.5
    threadA.threadPriority = 1.0;
    //2.启动线程
    [threadA start];

    NSThread *threadB = [[NSThread alloc]initWithTarget:self selector:@selector(run:) object:@"ABC"];
    threadB.name = @"线程b";
    threadB.threadPriority = 0.1;
    [threadB start];

    NSThread *threadC = [[NSThread alloc]initWithTarget:self selector:@selector(run:) object:@"ABC"];
    threadC.name = @"线程C";
    [threadC start];
}

//2.分离子线程,自动启动线程
-(void)createNewThread2
{
    [NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:@"分离子线程"];
}

//3.开启一条后台线程
-(void)createNewThread3
{
    [self performSelectorInBackground:@selector(run:) withObject:@"开启后台线程"];
}

-(void)run:(NSString *)param
{
//    NSLog(@"---run----%@---%@",[NSThread currentThread].name,param);
    for (NSInteger i = 0; i<20; i++) {
        
//        @synchronized (self) {
             
            NSLog(@"%zd----%@\n\n",i,[NSThread currentThread].name);
//        }
//        @synchronized 有多个线程时，同一时间只能有一个线程操作资源，其他线程进入休眠状态，直到当前线程结束时才被唤醒执行操作。
    }
}

#pragma mark - 线程状态
- (void)threadStatusAction{
    
    NSThread *thread =[[NSThread alloc]initWithTarget:self selector:@selector(task) object:nil];
    [thread start];
}

- (void)run1:(NSString *)param{
    
    NSLog(@"run----%@",[NSThread currentThread]);
    
    //阻塞线程
    //[NSThread sleepForTimeInterval:2.0];
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
    
    NSLog(@"end---");
}

-(void)task
{
    for (NSInteger i = 0; i<100 ;i++) {
        NSLog(@"%zd---%@",i,[NSThread currentThread]);
        
        if (i == 20) {
           // [NSThread exit];  //退出当前线程
            break;              //表示任务已经执行完毕.
        }
    }
}

#pragma mark - 线程安全
- (void)threadSafeDemo{
    
    //设置中票数
    self.threadA = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
    self.threadB = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
    self.threadC = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
      
    self.threadA.name = @"售票员A";
    self.threadB.name = @"售票员B";
    self.threadC.name = @"售票员C";
      
      //启动线程
      @synchronized(self) {
          
        [self.threadA start];
        [self.threadB start];
        [self.threadC start];
      }
}

- (void)saleTicket{
    
    while (YES) {
        
        @synchronized (self) {
            
               NSInteger count = self.totalCount;
                if (count >0) {
                          
        //            for (NSInteger i = 0; i<1000000; i++) {}
                    self.totalCount = count - 1;
                          //卖出去一张票
                    NSLog(@"%@卖出去了一张票,还剩下%zd张票\n\n", [NSThread currentThread].name,self.totalCount);
                      
                }else{
                    
                    NSLog(@"不要回公司上班了\n\n");
                    break;
                }
        }
    }
}

#pragma mark - GCD
//异步函数+并发队列:会开启多条线程,队列中的任务是并发执行
-(void)asyncConcurrent
{
    NSLog(@"\n\n\n");
    
    //1.创建队列
    /*
     第一个参数:C语言的字符串,标签
     第二个参数:队列的类型
        DISPATCH_QUEUE_CONCURRENT:并发
        DISPATCH_QUEUE_SERIAL:串行
     */
    //dispatch_queue_t queue = dispatch_queue_create("com.520it.download", DISPATCH_QUEUE_CONCURRENT);
    
    //获得全局并发队列
    /*
     第一个参数:优先级
     第二个参数:
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSLog(@"---satrt----%@",[NSThread currentThread]);
    
    //2.1>封装任务2>添加任务到队列中
    /*
     第一个参数:队列
     第二个参数:要执行的任务
     */
    dispatch_async(queue, ^{
        NSLog(@"download1----%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"download2----%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"download3----%@",[NSThread currentThread]);
    });
    
    NSLog(@"---end----%@",[NSThread currentThread]);
}

//异步函数+串行队列:会开线程,开一条线程,队列中的任务是串行执行的
-(void)asyncSerial
{
     NSLog(@"\n\n\n");
    //1.创建队列
    dispatch_queue_t queue = dispatch_queue_create("download", DISPATCH_QUEUE_SERIAL);
     
    NSLog(@"---satrt----%@",[NSThread currentThread]);
    
    //2.封装操作
    dispatch_async(queue, ^{
        NSLog(@"download1----%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"download2----%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"download3----%@",[NSThread currentThread]);
    });
     
    NSLog(@"---end----%@",[NSThread currentThread]);
}

//同步函数+并发队列:不会开线程,任务是串行执行的
-(void)syncConcurrent
{
    NSLog(@"\n\n\n");
    
    //1.创建队列
    dispatch_queue_t queue = dispatch_queue_create("com.520it.download", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"---start---%@\n",[NSThread currentThread]);
    //2.封装任务
    dispatch_sync(queue, ^{
        NSLog(@"download1----%@\n",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"download2----%@\n",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"download3----%@\n",[NSThread currentThread]);
    });
    
    NSLog(@"---end---%@",[NSThread currentThread]);
}

//同步函数+串行队列:不会开线程,任务是串行执行的
-(void)syncSerial
{
    NSLog(@"\n\n\n");
    
    //1.创建队列
    dispatch_queue_t queue = dispatch_queue_create("com.520it.download", DISPATCH_QUEUE_SERIAL);
    
    //2.封装任务
    dispatch_sync(queue, ^{
        NSLog(@"download1----%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"download2----%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"download3----%@",[NSThread currentThread]);
    });
}

//异步函数+主队列:所有任务都在主线程中执行,不会开线程
-(void)asyncMain
{
    NSLog(@"\n\n\n");
    
    //1.获得主队列
    dispatch_queue_t queue = dispatch_get_main_queue();

    //2.异步函数
    dispatch_async(queue, ^{
        NSLog(@"download1----%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"download2----%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"download3----%@",[NSThread currentThread]);
    });
}

//同步函数+主队列:死锁
//注意:如果该方法在子线程中执行,那么所有的任务在主线程中执行,
-(void)syncMain
{
    NSLog(@"\n\n\n");
    
    //1.获得主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    NSLog(@"start----");
    //2.同步函数
    //同步函数:立刻马上执行,如果我没有执行完毕,那么后面的也别想执行
    //异步函数:如果我没有执行完毕,那么后面的也可以执行
    dispatch_sync(queue, ^{
        NSLog(@"download1----%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"download2----%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"download3----%@",[NSThread currentThread]);
    });
    
    NSLog(@"end---");
}

#pragma mark - CGD线程之间通信
- (void)GCDCommunicate{
    
    //1.创建子线程下载图片
        //DISPATCH_QUEUE_PRIORITY_DEFAULT 0
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        //1.1 确定url
        NSURL *url = [NSURL URLWithString:@"http://a.hiphotos.baidu.com/zhidao/wh%3D450%2C600/sign=da0ec79c738da9774e7a8e2f8561d42f/c83d70cf3bc79f3d6842e09fbaa1cd11738b29f9.jpg"];

        //1.2 下载二进制数据到本地
        NSData *imageData =  [NSData dataWithContentsOfURL:url];
        
        //1.3 转换图片
        UIImage *image = [UIImage imageWithData:imageData];
        
        NSLog(@"download----%@",[NSThread currentThread]);
        
        //更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
//        dispatch_sync(dispatch_get_main_queue(), ^{
            
            self.imageView.image = image;
            NSLog(@"UI----%@",[NSThread currentThread]);
        });
        
    });
}

#pragma mark - GCD常用函数
//延迟执行
-(void)delay
{
    NSLog(@"start-----");
    
    //1. 延迟执行的第一种方法
    //[self performSelector:@selector(task) withObject:nil afterDelay:2.0];
    
    //2.延迟执行的第二种方法
    //[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(task) userInfo:nil repeats:YES];
    
    //3.GCD
//    dispatch_queue_t queue = dispatch_get_main_queue();
     dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    /*
     第一个参数:DISPATCH_TIME_NOW 从现在开始计算时间
     第二个参数:延迟的时间 2.0 GCD时间单位:纳秒
     第三个参数:队列
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), queue, ^{
        NSLog(@"GCD----%@",[NSThread currentThread]);
    });

}

//一次性代码
//不能放在懒加载中的,应用场景:单例模式
-(void)once
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"---once----");
    });
}

@end
