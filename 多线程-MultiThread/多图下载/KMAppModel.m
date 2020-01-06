//
//  KMAppModel.m
//  多图下载
//
//  Created by 贺刘敏 on 2020/1/3.
//  Copyright © 2020 hlm. All rights reserved.
//

#import "KMAppModel.h"

@implementation KMAppModel

+ (instancetype)appWithDict:(NSDictionary *)dict{
    
    KMAppModel *appM = [[KMAppModel alloc]init];
    //KVC
     [appM setValuesForKeysWithDictionary:dict];
     
     return appM;
}

@end
