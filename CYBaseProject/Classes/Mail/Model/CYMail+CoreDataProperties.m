//
//  CYMail+CoreDataProperties.m
//  
//
//  Created by Peter Lee on 2017/1/12.
//
//

#import "CYMail+CoreDataProperties.h"

@implementation CYMail (CoreDataProperties)

+ (NSFetchRequest<CYMail *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CYMail"];
}

@dynamic account;
@dynamic attachmentCount;
@dynamic bcc;
@dynamic cc;
@dynamic content;
@dynamic folderPath;
@dynamic fromAddress;
@dynamic fromName;
@dynamic flags;
@dynamic receivedDate;
@dynamic sendDate;
@dynamic subject;
@dynamic to;
@dynamic uid;
@dynamic attachments;

@end
