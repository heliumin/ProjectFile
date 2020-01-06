//
//  ViewController.m
//  多图下载
//
//  Created by 贺刘敏 on 2020/1/3.
//  Copyright © 2020 hlm. All rights reserved.
//

#import "ViewController.h"
#import "KMAppModel.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *apps;

/** 内存缓存 */
@property (nonatomic, strong) NSMutableDictionary *images;
/** 队列 */
@property (nonatomic, strong) NSOperationQueue *queue;
/** 操作缓存 */
@property (nonatomic, strong) NSMutableDictionary *operations;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.tableView reloadData];
}

#pragma mark UITableViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.apps.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"app";
    
    //1.创建cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    //2.设置cell的数据
    //2.1 拿到该行cell对应的数据
    KMAppModel *appM = self.apps[indexPath.row];
    
    //2.2 设置标题
    cell.textLabel.text = appM.name;
    
    //2.3 设置子标题
    cell.detailTextLabel.text = appM.download;
    
//    //2.4 设置图标
//    NSURL *url = [NSURL URLWithString:appM.icon];
//    NSData *imageData = [NSData dataWithContentsOfURL:url];
//    UIImage *image = [UIImage imageWithData:imageData];
//    cell.imageView.image = image;
//    NSLog(@"%zd-----",indexPath.row);
    
//    更便捷的方式就是使用SDWebImage来加载图片
    
    //先去查看内存缓存中该图片时候已经存在,如果存在那么久直接拿来用,否则去检查磁盘缓存
    //如果有磁盘缓存,那么保存一份到内存,设置图片,否则就直接下载
    //1)没有下载过
    //2)重新打开程序
    UIImage *image = [self.images objectForKey:appM.icon];
    if (image) {
        
        cell.imageView.image = image;
        NSLog(@"%zd处的图片使用了内存缓存中的图片",indexPath.row);
    }
    else{
        
        //保存图片到沙盒缓存
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        //获得图片的名称,不能包含/
        NSString *fileName = [appM.icon lastPathComponent];
        //拼接图片的全路径
        NSString *fullName = [caches stringByAppendingString:fileName];
        
        NSLog(@"fileName:%@\n",fileName);
        
        //检查磁盘缓存
        NSData *imageData = [NSData dataWithContentsOfFile:fullName];
//        imageData = nil;
        
        if (imageData) {
            
            UIImage *image1 = [UIImage imageWithData:imageData];
            cell.imageView.image = image1;
            
            //把图片保存到内存缓存
            [self.images setObject:image1 forKey:appM.icon];
            NSLog(@"%zd处的图片使用了硬盘中的图片",indexPath.row);
        }
        else{
            
            //检查该图片时候正在下载,如果是，那么就什么都不做，否则再添加下载任务
            NSBlockOperation *downLoad = [self.operations objectForKey:appM.icon];
            if (downLoad) {}
            else{
                
                cell.imageView.image = nil;
                downLoad =[NSBlockOperation blockOperationWithBlock:^{
                    
                    NSURL *url = [NSURL URLWithString:appM.icon];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    UIImage *image2 =[UIImage imageWithData:data];
                    
                    NSLog(@"%zd--下载---",indexPath.row);
                    if (image2 == nil) {
                        
                        [self.operations removeObjectForKey:appM.icon];
                        return ;
                    }
                    
                    //演示网速慢的情况
//                    [NSThread sleepForTimeInterval:3.0];
                       
                    //把图片保存到内存缓存
                    [self.images setObject:image2 forKey:appM.icon];
                    
                    //线程间通信
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
//                        cell.imageView.image = image2;
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    }];
                    
                    //写数据到沙盒
                    [data writeToFile:fullName atomically:YES];
                    
                    //移除图片的下载操作
                    [self.operations removeObjectForKey:appM.icon];
                }];
                
                //添加操作到操作缓存中
                [self.operations setObject:downLoad forKey:appM.icon];
                
                //添加操作到队列中
                [self.queue addOperation:downLoad];
            }
        }
    }
    
    //3.返回cell
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}

- (NSArray *)apps{
    
    if (!_apps) {
        
        NSString *path =[[NSBundle mainBundle] pathForResource:@"apps" ofType:@"plist"];
        NSArray *array =[NSArray arrayWithContentsOfFile:path];
        
//        字典转模型
        NSMutableArray *arrayM =[NSMutableArray array];
        for (NSDictionary *dic in array) {
            
            KMAppModel *appModel =[KMAppModel appWithDict:dic];
            [arrayM addObject:appModel];
        }
        _apps = [NSArray arrayWithArray:arrayM];
    }
    return _apps;
}

- (void)didReceiveMemoryWarning{
    
    [self.images removeAllObjects];
    
    [self.queue cancelAllOperations];
}

- (NSMutableDictionary *)images{
    
    if (!_images) {
        
        _images = [NSMutableDictionary dictionary];
    }
    return _images;
}

- (NSOperationQueue *)queue{
    
    if (!_queue) {
        
        _queue =[NSOperationQueue mainQueue];
        _queue.maxConcurrentOperationCount = 5;
    }
    return _queue;
}

- (NSMutableDictionary *)operations{
    
    if (!_operations) {
        
        _operations =[NSMutableDictionary dictionary];
    }
    return _operations;
}

/*
Documents:会备份,不允许
Libray
   Preferences:偏好设置 保存账号
   caches:缓存文件
tmp:临时路径(随时会被删除)
*/

@end
