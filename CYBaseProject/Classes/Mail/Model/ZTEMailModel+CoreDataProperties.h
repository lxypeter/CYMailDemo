//
//  ZTEMailModel+CoreDataProperties.h
//  CYMailDemo
//
//  Created by Peter Lee on 16/7/29.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZTEMailModel.h"

NS_ASSUME_NONNULL_BEGIN

@class ZTEMailAttachment;
@interface ZTEMailModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *attachmentCount;
@property (nullable, nonatomic, retain) NSString *bcc;
@property (nullable, nonatomic, retain) NSString *cc;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSString *folderPath;
@property (nullable, nonatomic, retain) NSString *fromAddress;
@property (nullable, nonatomic, retain) NSString *fromName;
@property (nullable, nonatomic, retain) NSString *ownerAddress;
@property (nullable, nonatomic, retain) NSNumber *read;
@property (nullable, nonatomic, retain) NSDate *receivedDate;
@property (nullable, nonatomic, retain) NSDate *sendDate;
@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSString *to;
@property (nullable, nonatomic, retain) NSNumber *uid;
@property (nullable, nonatomic, retain) NSSet<ZTEMailAttachment *> *attachments;

@end

@interface ZTEMailModel (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(ZTEMailAttachment *)value;
- (void)removeAttachmentsObject:(ZTEMailAttachment *)value;
- (void)addAttachments:(NSSet<ZTEMailAttachment *> *)values;
- (void)removeAttachments:(NSSet<ZTEMailAttachment *> *)values;

@end

NS_ASSUME_NONNULL_END
