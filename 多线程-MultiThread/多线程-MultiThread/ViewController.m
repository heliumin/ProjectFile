//
//  ViewController.m
//  MultiThread
//
//  Created by 贺刘敏 on 2019/12/31.
//  Copyright © 2019 hlm. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>
#import "KMTool.h"
#import "KMDownLoadTool.h"
#import "KMOperation.h"

@interface ViewController ()

/** 售票员A */
@property (nonatomic, strong) NSThread *threadA;
/** 售票员B */
@property (nonatomic, strong) NSThread *threadB;
/** 售票员C */
@property (nonatomic, strong) NSThread *threadC;

@property (nonatomic, assign) NSInteger totalCount;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

/** 图片1 */
@property (nonatomic, strong) UIImage *image1;
/** 图2 */
@property (nonatomic, strong) UIImage *image2;

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
    
//    [self GCDCommunicate];
    
//    [self GCDBarriarDemo];
    
//    [self GCDApplyDemo];
    
//    [self group3];
    
//    [self singleTonTest];
    
//    [self invocationOperation];
    [self blockOperation];
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

#pragma mark - GCD栅栏函数
- (void)GCDBarriarDemo{
    
    //0.获得全局并发队列
    //栅栏函数不能使用全局并发队列，如果使用全局并发队列达不到栅栏的效果，不信你试试
//    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue = dispatch_queue_create("download", DISPATCH_QUEUE_CONCURRENT);
    
    //1.异步函数
    dispatch_async(queue, ^{
       
        for (NSInteger i = 0; i<2; i++) {
            NSLog(@"download1-%zd-%@",i,[NSThread currentThread]);
        }
        
    });
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0; i<2; i++) {
            NSLog(@"download2-%zd-%@",i,[NSThread currentThread]);
        }
    });
    
    
    //栅栏函数
    dispatch_barrier_async(queue, ^{
       
        NSLog(@"\n\n+++++++++++++++++++++++++++++\n\n");
    });
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0; i<2; i++) {
            NSLog(@"download3-%zd-%@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0; i<2; i++) {
            NSLog(@"download4-%zd-%@",i,[NSThread currentThread]);
        }
    });
}

#pragma mark - GCD 快速迭代
- (void)GCDApplyDemo{
    
    //同步
//    for (NSInteger i = 0; i<10; i++) {
//
//        NSLog(@"%zd---%@",i,[NSThread currentThread]);
//    }
    
    /*
       第一个参数:遍历的次数
       第二个参数:队列(并发队列)
       第三个参数:index 索引
       */
    NSMutableArray *array =[NSMutableArray array];
    dispatch_apply(10, dispatch_get_global_queue(0, 0), ^(size_t index) {
    
        [array addObject:@(index)];
    });
    NSLog(@"array:%@\n",array);
}

//使用for循环
-(void)moveFile
{
    //1.拿到文件路径
    NSString *from = @"自己写...";
    
    //2.获得目标文件路径
    NSString *to = @"自己写...";
    
    //3.得到目录下面的所有文件
    NSArray *subPaths = [[NSFileManager defaultManager] subpathsAtPath:from];
    
    NSLog(@"%@",subPaths);
    //4.遍历所有文件,然后执行剪切操作
    NSInteger count = subPaths.count;
    
    for (NSInteger i = 0; i< count; i++) {
        
        //4.1 拼接文件的全路径
       // NSString *fullPath = [from stringByAppendingString:subPaths[i]];
        //在拼接的时候会自动添加/
        NSString *fullPath = [from stringByAppendingPathComponent:subPaths[i]];
        NSString *toFullPath = [to stringByAppendingPathComponent:subPaths[i]];
        
        NSLog(@"%@",fullPath);
        //4.2 执行剪切操作
        /*
         第一个参数:要剪切的文件在哪里
         第二个参数:文件应该被存到哪个位置
         */
        [[NSFileManager defaultManager]moveItemAtPath:fullPath toPath:toFullPath error:nil];
        
        NSLog(@"%@---%@--%@",fullPath,toFullPath,[NSThread currentThread]);
    }
}

-(void)moveFileWithGCD
{
    //1.拿到文件路径
    NSString *from = @"自己写...";
    
    //2.获得目标文件路径
    NSString *to = @"自己写...";
    
    //3.得到目录下面的所有文件
    NSArray *subPaths = [[NSFileManager defaultManager] subpathsAtPath:from];
    
    NSLog(@"%@",subPaths);
    //4.遍历所有文件,然后执行剪切操作
    NSInteger count = subPaths.count;
    
    dispatch_apply(count, dispatch_get_global_queue(0, 0), ^(size_t i) {
        //4.1 拼接文件的全路径
        // NSString *fullPath = [from stringByAppendingString:subPaths[i]];
        //在拼接的时候会自动添加/
        NSString *fullPath = [from stringByAppendingPathComponent:subPaths[i]];
        NSString *toFullPath = [to stringByAppendingPathComponent:subPaths[i]];
        
        NSLog(@"%@",fullPath);
        //4.2 执行剪切操作
        /*
         第一个参数:要剪切的文件在哪里
         第二个参数:文件应该被存到哪个位置
         */
        [[NSFileManager defaultManager]moveItemAtPath:fullPath toPath:toFullPath error:nil];
        
        NSLog(@"%@---%@--%@",fullPath,toFullPath,[NSThread currentThread]);
    });
}

#pragma mark - GCD 队列
-(void)group1
{
    //1.创建队列
    dispatch_queue_t queue =dispatch_get_global_queue(0, 0);
    
    //2.创建队列组
    dispatch_group_t group = dispatch_group_create();
    
    //3.异步函数
    /*
     1)封装任务
     2)把任务添加到队列中
     dispatch_async(queue, ^{
     NSLog(@"1----%@",[NSThread currentThread]);
     });
     */
    /*
     1)封装任务
     2)把任务添加到队列中
     3)会监听任务的执行情况,通知group
     */
    dispatch_group_async(group, queue, ^{
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"3----%@",[NSThread currentThread]);
    });
    
    //拦截通知,当队列组中所有的任务都执行完毕的时候回进入到下面的方法
    dispatch_group_notify(group, queue, ^{
        
        NSLog(@"-------dispatch_group_notify-------");
    });
    
    //    NSLog(@"----end----");

}

-(void)group2
{
    //1.创建队列
    dispatch_queue_t queue =dispatch_get_global_queue(0, 0);
    
    //2.创建队列组
    dispatch_group_t group = dispatch_group_create();
    
    //3.在该方法后面的异步任务会被纳入到队列组的监听范围,进入群组
    //dispatch_group_enter|dispatch_group_leave 必须要配对使用
    dispatch_group_enter(group);
    
    dispatch_async(queue, ^{
        NSLog(@"1----%@",[NSThread currentThread]);
        
        //离开群组
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    
    dispatch_async(queue, ^{
        NSLog(@"2----%@",[NSThread currentThread]);
    
        //离开群组
        dispatch_group_leave(group);
    });
    
    
    //拦截通知
    //问题?该方法是阻塞的吗?  内部本身是异步的
//    dispatch_group_notify(group, queue, ^{
//        NSLog(@"-------dispatch_group_notify-------");
//    });
    
    //等待.死等. 直到队列组中所有的任务都执行完毕之后才能执行
    //阻塞的
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"----end----");
    
}

-(void)group3
{
    /*
     1.下载图片1 开子线程
     2.下载图片2 开子线程
     3.合成图片并显示图片 开子线程
     */
    
    //-1.获得队列组
    dispatch_group_t group = dispatch_group_create();
    
    //0.获得并发队列
    dispatch_queue_t queue =  dispatch_get_global_queue(0, 0);
    
    // 1.下载图片1 开子线程
    dispatch_group_async(group, queue,^{
        
        NSLog(@"download1---%@",[NSThread currentThread]);
        //1.1 确定url
        NSURL *url = [NSURL URLWithString:@"http://www.qbaobei.com/tuku/images/13.jpg"];
        
        //1.2 下载二进制数据
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        
        //1.3 转换图片
        self.image1 = [UIImage imageWithData:imageData];
    });
    
    // 2.下载图片2 开子线程
     dispatch_group_async(group, queue,^{
         
         NSLog(@"download2---%@",[NSThread currentThread]);
         //2.1 确定url
        NSURL *url = [NSURL URLWithString:@"http://pic1a.nipic.com/2008-09-19/2008919134941443_2.jpg"];
        
        //2.2 下载二进制数据
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        
        //2.3 转换图片
        self.image2 = [UIImage imageWithData:imageData];
    });

    //3.合并图片
    //主线程中执行
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
       
        NSLog(@"combie---%@",[NSThread currentThread]);
        //3.1 创建图形上下文
        UIGraphicsBeginImageContext(CGSizeMake(200, 200));
        
        //3.2 画图1
        [self.image1 drawInRect:CGRectMake(0, 0, 200, 100)];
        self.image1 = nil;
        
        //3.3 画图2
        [self.image2 drawInRect:CGRectMake(0, 100, 200, 100)];
        self.image2 = nil;
        
        //3.4 根据上下文得到一张图片
        UIImage *image =  UIGraphicsGetImageFromCurrentImageContext();
        
        //3.5 关闭上下文
        UIGraphicsEndImageContext();
        
        //3.6 更新UI
//        dispatch_async(dispatch_get_main_queue(), ^{
        
            NSLog(@"UI----%@",[NSThread currentThread]);
            self.imageView.image = image;
//        });
    });
    
//    dispatch_release(group)
}

#pragma mark - 单例测试
- (void)singleTonTest{
    
    KMTool *t1 = [[KMTool alloc]init];
    KMTool *t2 = [[KMTool alloc]init];
    
    KMTool *t3 = [KMTool new];
    KMTool *t4 = [KMTool shareTool];
    
    KMTool *t5 = [t1 copy];
    KMTool *t6 = [t1 mutableCopy];
    
    NSLog(@"t1:%p t2:%p t3:%p t4:%p t5:%p t6:%p\n",t1,t2,t3,t4,t5,t6);
    
    KMDownLoadTool *downLoadTool1 = [KMDownLoadTool shareDownLoadTool];
    KMDownLoadTool *downLoadTool2 = [KMDownLoadTool new];
    KMDownLoadTool *downLoadTool3 = [[KMDownLoadTool alloc]init];
    
    NSLog(@"downLoadTool1:%p downLoadTool2:%p downLoadTool3:%p\n",downLoadTool1,downLoadTool2,downLoadTool3);
    
}

#pragma mark - NSOperation使用
- (void)invocationOperation{
    
    NSInvocationOperation *op1 =[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(download1) object:nil];
    
    NSInvocationOperation *op2 =[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(download2) object:nil];
    
    NSInvocationOperation *op3 =[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(download3) object:nil];
    
    [op1 start];
    [op2 start];
    [op3 start];
}

- (void)blockOperation{
    
    NSBlockOperation *op1 =[NSBlockOperation blockOperationWithBlock:^{
         
        NSLog(@"1----%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *op2 =[NSBlockOperation blockOperationWithBlock:^{
         
        NSLog(@"2----%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *op3 =[NSBlockOperation blockOperationWithBlock:^{
         
        NSLog(@"3----%@",[NSThread currentThread]);
    }];
    
    [op3 addExecutionBlock:^{
        
        NSLog(@"4----%@",[NSThread currentThread]);
    }];
    
    [op3 addExecutionBlock:^{
        
        NSLog(@"5----%@",[NSThread currentThread]);
    }];
    
    [op3 addExecutionBlock:^{
        
        NSLog(@"6----%@",[NSThread currentThread]);
    }];
    
    /*
     同一个的operation的block顺序部分先后，operation顺序执行
     
     //追加任务
     //注意:如果一个操作中的任务数量大于1,那么会开子线程并发执行任务
     //注意:不一定是子线程,有可能是主线程
     */

    [op1 start];
    [op2 start];
    [op3 start];
}

-(void)download1
{
    NSLog(@"%s----%@",__func__,[NSThread currentThread]);
}

-(void)download2
{
    NSLog(@"%s----%@",__func__,[NSThread currentThread]);
}


-(void)download3
{
    NSLog(@"%s----%@",__func__,[NSThread currentThread]);
}

#pragma mark - NSOperationQueue使用
-(void)invocationOperationWithQueue
{
    //1.创建操作,封装任务
    /*
     第一个参数:目标对象 self
     第二个参数:调用方法的名称
     第三个参数:前面方法需要接受的参数 nil
     */
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(download1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(download2) object:nil];
    NSInvocationOperation *op3 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(download3) object:nil];
    
    //2.创建队列
    /*
     GCD:
     串行类型:create & 主队列
     并发类型:create & 全局并发队列
     NSOperation:
     主队列:   [NSOperationQueue mainQueue] 和GCD中的主队列一样,串行队列
     非主队列: [[NSOperationQueue alloc]init]  非常特殊(同时具备并发和串行的功能)
     //默认情况下,非主队列是并发队列
     */
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    //3.添加操作到队列中
    [queue addOperation:op1];   //内部已经调用了[op1 start]
    [queue addOperation:op2];
    [queue addOperation:op3];
}

-(void)blockOperationWithQueue
{
    //1.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1----%@",[NSThread currentThread]);
       
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2----%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"3----%@",[NSThread currentThread]);
    }];
    
    //追加任务
    [op2 addExecutionBlock:^{
        NSLog(@"4----%@",[NSThread currentThread]);
    }];
    
    [op2 addExecutionBlock:^{
        NSLog(@"5----%@",[NSThread currentThread]);
    }];
    
    [op2 addExecutionBlock:^{
        NSLog(@"6----%@",[NSThread currentThread]);
    }];
    
    //2.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    //3.添加操作到队列
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    
    //简便方法
    //1)创建操作,2)添加操作到队列中
    [queue addOperationWithBlock:^{
        NSLog(@"7----%@",[NSThread currentThread]);
    }];
}

-(void)customWithQueue
{
    //1.封装操作
    KMOperation *op1 = [[KMOperation alloc]init];
    KMOperation *op2 = [[KMOperation alloc]init];
    
    //2.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    //3.添加操作到队列
    [queue addOperation:op1];
    [queue addOperation:op2];
    
}


@end
