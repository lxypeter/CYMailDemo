//
//  CYFolder+CoreDataProperties.h
//  
//
//  Created by Peter Lee on 2017/1/12.
//
//

#import "CYFolder.h"


NS_ASSUME_NONNULL_BEGIN

@interface CYFolder (CoreDataProperties)

+ (NSFetchRequest<CYFolder *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *firstUid;
@property (nullable, nonatomic, copy) NSNumber *flags;
@property (nullable, nonatomic, copy) NSNumber *messageCount;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *nextUid;
@property (nullable, nonatomic, copy) NSString *path;
@property (nullable, nonatomic, copy) NSNumber *recentCount;
@property (nullable, nonatomic, copy) NSNumber *unseenCount;
@property (nullable, nonatomic, retain) CYMailAccount *account;

@end

NS_ASSUME_NONNULL_END
