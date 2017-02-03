//
//  CYAttachment+CoreDataProperties.m
//  
//
//  Created by Peter Lee on 2017/1/12.
//
//

#import "CYAttachment+CoreDataProperties.h"

@implementation CYAttachment (CoreDataProperties)

+ (NSFetchRequest<CYAttachment *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CYAttachment"];
}

@dynamic filename;
@dynamic folderPath;
@dynamic partid;
@dynamic uid;
@dynamic ownerMail;

@end
