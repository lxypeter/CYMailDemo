//
//  MailTopicCell.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/11.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailTopicCell.h"

@interface MailTopicCell ()

@property (weak, nonatomic) IBOutlet UITextView *topicTextView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation MailTopicCell

@dynamic content;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.titleLabel.text = MsgSubject;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
}

- (IBAction)clickAttachButton:(id)sender {
    if (self.attachBlock) {
        self.attachBlock();
    }
}

- (void)setContent:(NSString *)content{
    self.topicTextView.text = content;
}

- (NSString *)content{
    return self.topicTextView.text;
}

@end
