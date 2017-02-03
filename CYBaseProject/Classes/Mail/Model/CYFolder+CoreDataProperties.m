//
//  CYFolder+CoreDataProperties.m
//  
//
//  Created by Peter Lee on 2017/1/12.
//
//

#import "CYFolder+CoreDataProperties.h"

@implementation CYFolder (CoreDataProperties)

+ (NSFetchRequest<CYFolder *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CYFolder"];
}

@dynamic firstUid;
@dynamic flags;
@dynamic messageCount;
@dynamic name;
@dynamic nextUid;
@dynamic path;
@dynamic recentCount;
@dynamic unseenCount;
@dynamic account;

@end
