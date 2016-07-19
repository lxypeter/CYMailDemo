//
//  ZTEMailModel+CoreDataProperties.m
//  HNPositionAsst
//
//  Created by Peter Lee on 16/7/13.
//  Copyright © 2016年 YYang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZTEMailModel+CoreDataProperties.h"

@implementation ZTEMailModel (CoreDataProperties)

@dynamic uid;
@dynamic subject;
@dynamic fromName;
@dynamic fromAddress;
@dynamic sendDate;
@dynamic receivedDate;
@dynamic read;
@dynamic folderPath;
@dynamic ownerAddress;

@end
