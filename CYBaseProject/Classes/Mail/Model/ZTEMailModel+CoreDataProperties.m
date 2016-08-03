//
//  ZTEMailModel+CoreDataProperties.m
//  CYMailDemo
//
//  Created by Peter Lee on 16/7/29.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZTEMailModel+CoreDataProperties.h"

@implementation ZTEMailModel (CoreDataProperties)

@dynamic attachmentCount;
@dynamic bcc;
@dynamic cc;
@dynamic content;
@dynamic folderPath;
@dynamic fromAddress;
@dynamic fromName;
@dynamic ownerAddress;
@dynamic read;
@dynamic receivedDate;
@dynamic sendDate;
@dynamic subject;
@dynamic to;
@dynamic uid;
@dynamic attachments;

@end
