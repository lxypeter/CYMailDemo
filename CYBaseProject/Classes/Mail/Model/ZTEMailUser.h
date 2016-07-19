//
//  ZTEMailUser.h
//  HNPositionAsst
//
//  Created by Peter Lee on 16/5/20.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const ZTEMailUsersKey = @"ZTEMailUsers";

@interface ZTEMailUser : NSObject

@property (nonatomic, copy) NSString *username; // 邮箱用户名
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *serverName; // 邮箱服务器名称
@property (nonatomic, copy) NSString *nickName; // 邮箱别名
@property (nonatomic, copy) NSString *realName; // 用户真实姓名
@property (nonatomic, copy) NSString *fetchMailHost;
@property (nonatomic, assign) NSInteger fetchMailPort;
@property (nonatomic, copy) NSString *sendMailHost;
@property (nonatomic, assign) NSInteger sendMailPort;
@property (nonatomic, copy) NSString *mailStoreProtocol;
@property (nonatomic, assign) BOOL ssl;

+ (ZTEMailUser *)shareUser;

+ (NSMutableArray *)mailAccounts;

+ (void)storeAccountInfo:(ZTEMailUser *)userInfo;
+ (void)clearAccountInfo:(ZTEMailUser *)userInfo;
+ (BOOL)hasAddedAccountInfo:(NSString *)username;

- (void)configureWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)transferToDictionary;
- (void)clear;

@end
