//
//  CYMailAccount+CoreDataProperties.m
//  
//
//  Created by Peter Lee on 2017/1/12.
//
//

#import "CYMailAccount+CoreDataProperties.h"

@implementation CYMailAccount (CoreDataProperties)

+ (NSFetchRequest<CYMailAccount *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CYMailAccount"];
}

@dynamic fetchHost;
@dynamic fetchPort;
@dynamic nickName;
@dynamic password;
@dynamic sendHost;
@dynamic sendPort;
@dynamic smtpAuthType;
@dynamic ssl;
@dynamic username;
@dynamic folders;

@end
