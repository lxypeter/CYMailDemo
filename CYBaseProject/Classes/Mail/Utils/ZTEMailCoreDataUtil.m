//
//  ZTECoreDataUtil.m
//  HNPositionAsst
//
//  Created by Peter Lee on 16/7/13.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "ZTEMailCoreDataUtil.h"
#import <CoreData/CoreData.h>

@implementation ZTEMailCoreDataUtil

+ (NSManagedObjectContext *)shareContext{
    
    static NSManagedObjectContext *context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[NSManagedObjectContext alloc] init];
        
        // 创建一个模型对象
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        // 持久化存储调度器
        NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // 存储数据库的名字
        NSError *error = nil;
        
        // 获取docment目录
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        // 数据库保存的路径
        NSString *sqlitePath = [doc stringByAppendingFormat:@"/ZTEMailModel.slqite"];
        NSLog(@"path =====> %@",sqlitePath);
        
        [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlitePath] options:nil error:&error];
        
        context.persistentStoreCoordinator = store;
        
    });
    
    return context;
}

@end
