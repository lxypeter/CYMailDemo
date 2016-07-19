//
//  ZTEFolderModel+CoreDataProperties.m
//  HNPositionAsst
//
//  Created by Peter Lee on 16/7/15.
//  Copyright © 2016年 YYang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZTEFolderModel+CoreDataProperties.h"

@implementation ZTEFolderModel (CoreDataProperties)

@dynamic name;
@dynamic path;
@dynamic unseenCount;
@dynamic recentCount;
@dynamic messageCount;
@dynamic firstUid;
@dynamic nextUid;
@dynamic ownerAddress;
@dynamic flags;

@end
