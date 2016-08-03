//
//  ZTEMailUser+CoreDataProperties.m
//  CYMailDemo
//
//  Created by Peter Lee on 16/7/29.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZTEMailUser+CoreDataProperties.h"

@implementation ZTEMailUser (CoreDataProperties)

@dynamic username;
@dynamic serverName;
@dynamic password;
@dynamic sendMailHost;
@dynamic mailStoreProtocol;
@dynamic fetchMailPort;
@dynamic sendMailPort;
@dynamic nickName;
@dynamic ssl;
@dynamic smtpAuthType;
@dynamic fetchMailHost;

@end
