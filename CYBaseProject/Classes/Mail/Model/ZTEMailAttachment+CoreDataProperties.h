//
//  ZTEMailAttachment+CoreDataProperties.h
//  HNPositionAsst
//
//  Created by Peter Lee on 16/7/14.
//  Copyright © 2016年 YYang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZTEMailAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZTEMailAttachment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *ownerAddress;
@property (nullable, nonatomic, retain) NSString *partid;
@property (nullable, nonatomic, retain) NSString *filename;
@property (nullable, nonatomic, retain) NSString *folderPath;
@property (nullable, nonatomic, retain) NSNumber *uid;

@end

NS_ASSUME_NONNULL_END
