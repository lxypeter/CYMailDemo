//
//  MailContactCell.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/23.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailContactCell.h"

@implementation MailContactCellModel

@end

@interface MailContactCell ()

@property (nonatomic, strong) UIImageView *accImageView;

@end

@implementation MailContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
    self.accessoryView = imageView;
    self.accImageView = imageView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
}

- (void)setModel:(MailContactCellModel *)model{
    _model = model;
    
    self.titleLabel.text = model.title;
    self.contentLabel.text = [model.content stringByReplacingOccurrencesOfString:@";" withString:@";\n"];
}

- (void)setMailAccessoryType:(MailAccessoryType)mailAccessoryType{
    _mailAccessoryType = mailAccessoryType;
    switch (mailAccessoryType) {
        case MailAccessoryTypeNone:
            self.accImageView.image = nil;
            break;
        case MailAccessoryTypeFold:
            self.accImageView.image = [UIImage imageNamed:ImageFold];
            break;
        case MailAccessoryTypeUnfold:
            self.accImageView.image = [UIImage imageNamed:ImageUnfold];
            break;
    }
}

@end
