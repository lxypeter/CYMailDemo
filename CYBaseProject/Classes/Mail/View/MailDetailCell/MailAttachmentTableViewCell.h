//
//  MailAttachmentTableViewCell.h
//  GXMoblieOA
//
//  Created by Mon-work on 5/9/16.
//  Copyright © 2016 YYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MailAttachmentTableViewCell;

typedef enum : NSUInteger {
    MailAttachmentStatusDownloaded, // 未下载的附件
    MailAttachmentStatusToDownload, // 已下载的附件
} MailAttachmentStatus;

// 按下下载／打开附件时用
typedef void(^AttachmentOperation)(MailAttachmentTableViewCell *);

@interface MailAttachmentTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *lbPrefix; // 附件x
@property (nonatomic, strong) UILabel *lbName; // 附件名称
@property (nonatomic, strong) UIButton *btnOperation; // 对附件的操作，包括下载，打开
@property (nonatomic, assign) MailAttachmentStatus status;
@property (nonatomic, copy) AttachmentOperation operation;


+ (NSString *)reuseIdentifier;

@end
