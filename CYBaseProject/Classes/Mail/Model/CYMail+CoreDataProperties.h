//
//  CYMail+CoreDataProperties.h
//  
//
//  Created by Peter Lee on 2017/1/12.
//
//

#import "CYMail.h"


NS_ASSUME_NONNULL_BEGIN

@interface CYMail (CoreDataProperties)

+ (NSFetchRequest<CYMail *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *account;
@property (nullable, nonatomic, copy) NSNumber *attachmentCount;
@property (nullable, nonatomic, copy) NSString *bcc;
@property (nullable, nonatomic, copy) NSString *cc;
@property (nullable, nonatomic, copy) NSString *content;
@property (nullable, nonatomic, copy) NSString *folderPath;
@property (nullable, nonatomic, copy) NSString *fromAddress;
@property (nullable, nonatomic, copy) NSString *fromName;
@property (nullable, nonatomic, copy) NSNumber *flags;
@property (nullable, nonatomic, copy) NSDate *receivedDate;
@property (nullable, nonatomic, copy) NSDate *sendDate;
@property (nullable, nonatomic, copy) NSString *subject;
@property (nullable, nonatomic, copy) NSString *to;
@property (nullable, nonatomic, copy) NSNumber *uid;
@property (nullable, nonatomic, retain) NSSet<CYAttachment *> *attachments;

@end

@interface CYMail (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(CYAttachment *)value;
- (void)removeAttachmentsObject:(CYAttachment *)value;
- (void)addAttachments:(NSSet<CYAttachment *> *)values;
- (void)removeAttachments:(NSSet<CYAttachment *> *)values;

@end

NS_ASSUME_NONNULL_END
