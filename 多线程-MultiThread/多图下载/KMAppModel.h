//
//  KMAppModel.h
//  多图下载
//
//  Created by 贺刘敏 on 2020/1/3.
//  Copyright © 2020 hlm. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KMAppModel : NSObject

/* APP的名称 */
@property (nonatomic, strong) NSString *name;
/* APP的图片的url地址 */
@property (nonatomic, strong) NSString *icon;
/* APP的下载量 */
@property (nonatomic, strong) NSString *download;

+(instancetype)appWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
