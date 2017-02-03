//
//  CYAttachment+CoreDataProperties.h
//  
//
//  Created by Peter Lee on 2017/1/12.
//
//

#import "CYAttachment.h"


NS_ASSUME_NONNULL_BEGIN

@interface CYAttachment (CoreDataProperties)

+ (NSFetchRequest<CYAttachment *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *filename;
@property (nullable, nonatomic, copy) NSString *folderPath;
@property (nullable, nonatomic, copy) NSString *partid;
@property (nullable, nonatomic, copy) NSNumber *uid;
@property (nullable, nonatomic, retain) CYMail *ownerMail;

@end

NS_ASSUME_NONNULL_END
