//
//  ZTEMailUser+CoreDataProperties.h
//  CYMailDemo
//
//  Created by Peter Lee on 16/7/29.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZTEMailUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZTEMailUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSString *serverName;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSString *sendMailHost;
@property (nullable, nonatomic, retain) NSString *mailStoreProtocol;
@property (nonatomic) int16_t fetchMailPort;
@property (nonatomic) int16_t sendMailPort;
@property (nullable, nonatomic, retain) NSString *nickName;
@property (nonatomic) BOOL ssl;
@property (nonatomic) int32_t smtpAuthType;
@property (nullable, nonatomic, retain) NSString *fetchMailHost;

@end

NS_ASSUME_NONNULL_END
