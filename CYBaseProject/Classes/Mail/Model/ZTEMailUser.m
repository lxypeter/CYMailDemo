//
//  ZTEMailUser.m
//  HNPositionAsst
//
//  Created by Peter Lee on 16/5/20.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "ZTEMailUser.h"

@implementation ZTEMailUser

+ (ZTEMailUser *)shareUser{
    static ZTEMailUser *user;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[ZTEMailUser alloc]init];
    });
    return user;
}

+ (NSMutableArray *)mailAccounts{
    NSArray *userArray = [[NSUserDefaults standardUserDefaults] arrayForKey:ZTEMailUsersKey];
    NSMutableArray *mAccounts = [NSMutableArray array];
    for (NSDictionary *info in userArray) {
        ZTEMailUser *user = [[ZTEMailUser alloc] init];
        [user configureWithDictionary:info];
        [mAccounts addObject:user];
    }
    return mAccounts;
}

+ (NSArray *)mailAccountsDict{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:ZTEMailUsersKey];
}

+ (void)storeAccountInfo:(ZTEMailUser *)userInfo{
    NSDictionary *userInfoDict = [userInfo transferToDictionary];
    NSArray *accounts = [self mailAccountsDict];
    NSMutableArray *mAccounts = [NSMutableArray arrayWithArray:accounts];
    [mAccounts addObject:userInfoDict];
    [[NSUserDefaults standardUserDefaults] setValue:[mAccounts copy] forKey:ZTEMailUsersKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)clearAccountInfo:(ZTEMailUser *)userInfo{
    
    NSArray *accounts = [self mailAccountsDict];
    NSMutableArray *mAccounts = [NSMutableArray arrayWithArray:accounts];
    for (NSDictionary *info in mAccounts) {
        BOOL userNameMatches = [info[@"username"] isEqualToString:userInfo.username];

        if (userNameMatches) {
            [mAccounts removeObject:info];
            [[NSUserDefaults standardUserDefaults] setValue:[mAccounts copy] forKey:ZTEMailUsersKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }
    }
}

+ (BOOL)hasAddedAccountInfo:(NSString *)username{
    NSMutableArray *accounts = [self mailAccounts];
    for (ZTEMailUser *userInfo in accounts) {
        if ([userInfo.username isEqualToString:username]) {
            return YES;
        }
    }
    return NO;
}

- (void)configureWithDictionary:(NSDictionary *)dict{
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *methodName = [NSString stringWithFormat:@"set%@:",[NSString stringWithFormat:@"%@%@",[[key substringToIndex:1]uppercaseString],[key substringFromIndex:1]]];
        if ([self respondsToSelector:NSSelectorFromString(methodName)]) {
            [self setValue:obj forKey:key];
        }
    }];
    
}

- (NSDictionary *)transferToDictionary{
    return @{
             @"username":self.username == nil?@"":self.username,
             @"password":self.password == nil?@"":self.password,
             @"fetchMailHost":self.fetchMailHost == nil?@"":self.fetchMailHost,
             @"fetchMailPort":@(self.fetchMailPort),
             @"sendMailHost":self.sendMailHost == nil?@"":self.sendMailHost,
             @"sendMailPort":@(self.sendMailPort),
             @"mailStoreProtocol":self.mailStoreProtocol == nil?@"":self.mailStoreProtocol,
             @"serverName":self.serverName.length == 0 ? @"" : self.serverName,
             @"nickName":self.nickName.length == 0 ? self.username : self.nickName,
             @"realName":self.realName.length == 0 ? @"" : self.realName,
             @"ssl":@(self.ssl)
             };
}

- (void)clear{
    self.username          = nil;
    self.password          = nil;
    self.fetchMailHost     = nil;
    self.fetchMailPort     = 0;
    self.sendMailHost      = nil;
    self.sendMailPort      = 0;
    self.mailStoreProtocol = nil;
    self.serverName        = nil;
    self.nickName          = nil;
    self.realName      = nil;
    
}

@end
