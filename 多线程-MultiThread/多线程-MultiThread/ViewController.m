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

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.totalCount = 100;
}

- (IBAction)btnAction:(id)sender {
 
//    [self pthreadDemo];
    
//    [self createNSThreadDemo];
    
    [self threadSafeDemo];
    
    
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

@end
