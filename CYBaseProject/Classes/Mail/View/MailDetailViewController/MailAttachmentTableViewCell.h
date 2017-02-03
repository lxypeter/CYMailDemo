//
//  MailAttachmentTableViewCell.h
//  GXMoblieOA
//
//  Created by Mon-work on 5/9/16.
//  Copyright © 2016 YYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MailAttachmentTableViewCell;

typedef void(^AttachmentOperation)();

@class CYAttachment;
@interface MailAttachmentTableViewCell : UITableViewCell

@property (nonatomic, strong) CYAttachment *attachment;
@property (nonatomic, copy) AttachmentOperation openBlock;
@property (nonatomic, copy) AttachmentOperation downloadBlock;

+ (NSString *)reuseIdentifier;

@end
