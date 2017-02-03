//
//  CYMailAccount+CoreDataProperties.h
//  
//
//  Created by Peter Lee on 2017/1/12.
//
//

#import "CYMailAccount.h"


NS_ASSUME_NONNULL_BEGIN

@interface CYMailAccount (CoreDataProperties)

+ (NSFetchRequest<CYMailAccount *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *fetchHost;
@property (nullable, nonatomic, copy) NSNumber *fetchPort;
@property (nullable, nonatomic, copy) NSString *nickName;
@property (nullable, nonatomic, copy) NSString *password;
@property (nullable, nonatomic, copy) NSString *sendHost;
@property (nullable, nonatomic, copy) NSNumber *sendPort;
@property (nullable, nonatomic, copy) NSNumber *smtpAuthType;
@property (nullable, nonatomic, copy) NSNumber *ssl;
@property (nullable, nonatomic, copy) NSString *username;
@property (nullable, nonatomic, retain) NSSet<CYFolder *> *folders;

@end

@interface CYMailAccount (CoreDataGeneratedAccessors)

- (void)addFoldersObject:(CYFolder *)value;
- (void)removeFoldersObject:(CYFolder *)value;
- (void)addFolders:(NSSet<CYFolder *> *)values;
- (void)removeFolders:(NSSet<CYFolder *> *)values;

@end

NS_ASSUME_NONNULL_END
