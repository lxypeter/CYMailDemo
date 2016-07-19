//
//  MailAttachmentTableViewCell.m
//  GXMoblieOA
//
//  Created by Mon-work on 5/9/16.
//  Copyright © 2016 YYang. All rights reserved.
//

#import "Masonry.h"
#import "MailAttachmentTableViewCell.h"

@implementation MailAttachmentTableViewCell

#pragma mark - System Methods
+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setupSubviews];
    }
    
    return self;
}

- (void)updateConstraints{
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.bottom.equalTo(_lbName);
    }];
    
    [_lbPrefix mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(8.f);
        make.centerY.equalTo(self.contentView);
    }];
    
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(_lbPrefix.mas_right).offset(8.f);
        make.right.equalTo(_btnOperation.mas_left).offset(-8.f);
    }];
    
    [_btnOperation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(@(-8.f));
        make.size.mas_equalTo(CGSizeMake(30.f, 30.f));
    }];
    
    [super updateConstraints];
}

#pragma mark -
- (void)setupSubviews{
    _lbPrefix             = [[UILabel alloc] init];
    _lbName               = [[UILabel alloc] init];
    _lbName.numberOfLines = 3;
    _lbName.adjustsFontSizeToFitWidth = YES;
    _lbName.minimumScaleFactor = 0.8;//字体大小缩放比例[0~1.0]
    _btnOperation         = [[UIButton alloc] init];
    [_btnOperation addTarget:self action:@selector(btnOperationClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_lbPrefix];
    [self.contentView addSubview:_lbName];
    [self.contentView addSubview:_btnOperation];
}

- (void)btnOperationClicked:(UIButton *)sender{
    if (self.operation) {
        __weak typeof(self) weakSelf = self;
        self.operation(weakSelf);
    }
}

+ (NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

#pragma mark - Accessors
- (void)setStatus:(MailAttachmentStatus)status{
    _status = status;
    if (_status == MailAttachmentStatusDownloaded) {
        [self.btnOperation setBackgroundImage:[UIImage imageNamed:@"app_supermarket_download_open"] forState:UIControlStateNormal];
    } else {
        [self.btnOperation setBackgroundImage:[UIImage imageNamed:@"app_supermarket_download_nor"] forState:UIControlStateNormal];
        [self.btnOperation setBackgroundImage:[UIImage imageNamed:@"app_supermarket_download_pre"] forState:UIControlStateHighlighted];
    }
}

@end
