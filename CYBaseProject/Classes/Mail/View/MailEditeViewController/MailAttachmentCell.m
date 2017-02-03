//
//  MailAttachmentCell.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/11.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailAttachmentCell.h"
#import "CYTempAttachment.h"

@interface MailAttachmentCell ()

@property (weak, nonatomic) IBOutlet UILabel *attchmentLabel;

@end

@implementation MailAttachmentCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
}

- (void)setAttachment:(CYTempAttachment *)attachment{
    _attachment = attachment;
    self.attchmentLabel.text = attachment.fileName;
}

@end
