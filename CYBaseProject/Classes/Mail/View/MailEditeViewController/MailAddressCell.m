//
//  MailAddressCell.m
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/31.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import "MailAddressCell.h"
#import <YYTextView.h>
#import "MailAddAddrTextParser.h"
#import <Masonry.h>

@interface MailAddressCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) YYTextView *contentTextView;

@end

@implementation MailAddressCell

@dynamic title;
@dynamic content;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setupSubviews];
    }
    
    return self;
}

- (void)updateConstraints{
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.width.mas_equalTo(60);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [_contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(8);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-8);
        make.left.equalTo(_titleLabel.mas_right).offset(8);
        make.right.equalTo(self.contentView.mas_right).offset(-8);
    }];
    
    [super updateConstraints];
}

- (void)setupSubviews{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = UICOLOR(@"#797979");
    _titleLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:_titleLabel];
    
    _contentTextView = [[YYTextView alloc]init];
    _contentTextView.textParser = [MailAddAddrTextParser new];
    _contentTextView.font = [UIFont systemFontOfSize:15];
    _contentTextView.placeholderText = MsgAddrPlaceholder;
    [self.contentView addSubview:_contentTextView];
}

#pragma mark - Getter/Setter
- (void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}

- (NSString *)title{
    return self.titleLabel.text;
}

- (void)setContent:(NSString *)content{
    self.contentTextView.text = content;
}

- (NSString *)content{
    return self.contentTextView.text;
}

@end
