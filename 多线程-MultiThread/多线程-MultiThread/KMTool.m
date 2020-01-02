//
//  KMTool.m
//  多线程-MultiThread
//
//  Created by 贺刘敏 on 2020/1/2.
//  Copyright © 2020 hlm. All rights reserved.
//

#import "KMTool.h"

@implementation KMTool

//0.提供全局变量
static KMTool *_instance;

//1.alloc-->allocWithZone
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    //加互斥锁解决多线程访问安全问题
//    @synchronized(self) {
//        if (_instance == nil) {
//            _instance = [super allocWithZone:zone];
//        }
//    }
    
    //本身就是线程安全的
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    
    return _instance;
}

//2.提供类方法
+(instancetype)shareTool
{
    return [[self alloc]init];
}

//3.严谨
-(id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone
{
    return _instance;
}

#if __has_feature(objc_arc)
//条件满足 ARC
#else
// MRC
-(oneway void)release
{
}

-(instancetype)retain
{
    return _instance;
}

//习惯
-(NSUInteger)retainCount
{
    return MAXFLOAT;
}

#endif
 
@end
