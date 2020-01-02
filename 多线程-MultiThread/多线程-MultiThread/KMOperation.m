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
    
    NSLog(@"main--%@",[NSThread currentThread]);
}

@end
