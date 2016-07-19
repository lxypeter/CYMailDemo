//
//  ZTECoreDataUtil.h
//  HNPositionAsst
//
//  Created by Peter Lee on 16/7/13.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContextp;
@interface ZTEMailCoreDataUtil : NSObject

+ (NSManagedObjectContext *)shareContext;

@end
