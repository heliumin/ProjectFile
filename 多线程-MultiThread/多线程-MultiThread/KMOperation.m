//
//  KMOperation.m
//  多线程-MultiThread
//
//  Created by 贺刘敏 on 2020/1/2.
//  Copyright © 2020 hlm. All rights reserved.
//

#import "KMOperation.h"

@implementation KMOperation

//告知要执行的任务是什么
//1.有利于代码隐蔽
//2.复用性
- (void)main{
    
    //3个耗时操作
    for (NSInteger i = 0; i<100000;i++ ) {
        NSLog(@"download1---%zd--%@",i,[NSThread currentThread]);
    }
    
    //苹果官方的建议:每执行完一小段耗时操作的时候判断当前操作时候被取消
    if(self.isCancelled) return;
    
    NSLog(@"+++++++++++++++");
    
    for (NSInteger i = 0; i<1000;i++ ) {
        NSLog(@"download2---%zd--%@",i,[NSThread currentThread]);
    }
    
    if(self.isCancelled) return;
    NSLog(@"+++++++++++++++");
    
    for (NSInteger i = 0; i<1000;i++ ) {
        NSLog(@"download3---%zd--%@",i,[NSThread currentThread]);
    }
}

@end
