//
//  MailListCell.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/10.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailListCell.h"
#import "CYMail.h"

@implementation MailListCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setMail:(CYMail *)mail{
    _mail = mail;
    
    NSString *subject = mail.subject;
    if (!subject||subject.length==0) {
        subject = @"(无题)";
    }
    self.contentLabel.text = subject;
    
    NSString *from = mail.fromName;
    if ([NSString isBlankString:from]) {
        from = mail.fromAddress;
    }
    self.departmentLabel.text = from;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    self.timeLabel.text = [formatter stringFromDate:mail.receivedDate];
    self.attachIconImageView.hidden = ([mail.attachmentCount integerValue]<=0);
    //MCOMessageFlagSeen = 1 << 0
    self.unReadImage.hidden = [mail.flags integerValue]&(1 << 0);
}

@end
