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

@implementation MailContactCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(MailContactCellModel *)model{
    _model = model;
    
    self.titleLabel.text = model.title;
    self.contentLabel.text = [model.content stringByReplacingOccurrencesOfString:@";" withString:@";\n"];
}

@end
