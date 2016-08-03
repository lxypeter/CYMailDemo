//
//  ZTEMailAttachment+CoreDataProperties.h
//  CYMailDemo
//
//  Created by Peter Lee on 16/7/29.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZTEMailAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@class ZTEMailModel;
@interface ZTEMailAttachment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *filename;
@property (nullable, nonatomic, retain) NSString *folderPath;
@property (nullable, nonatomic, retain) NSString *partid;
@property (nullable, nonatomic, retain) NSNumber *uid;
@property (nullable, nonatomic, retain) ZTEMailModel *ownerMail;

@end

NS_ASSUME_NONNULL_END
