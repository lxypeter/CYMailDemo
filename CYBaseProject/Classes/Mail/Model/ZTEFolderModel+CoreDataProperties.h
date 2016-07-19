//
//  ZTEFolderModel+CoreDataProperties.h
//  HNPositionAsst
//
//  Created by Peter Lee on 16/7/15.
//  Copyright © 2016年 YYang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZTEFolderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZTEFolderModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *path;
@property (nullable, nonatomic, retain) NSNumber *unseenCount;
@property (nullable, nonatomic, retain) NSNumber *recentCount;
@property (nullable, nonatomic, retain) NSNumber *messageCount;
@property (nullable, nonatomic, retain) NSNumber *firstUid;
@property (nullable, nonatomic, retain) NSNumber *nextUid;
@property (nullable, nonatomic, retain) NSString *ownerAddress;
@property (nullable, nonatomic, retain) NSNumber *flags;

@end

NS_ASSUME_NONNULL_END
