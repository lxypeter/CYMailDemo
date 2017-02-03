//
//  MailAttachmentTableViewCell.m
//  GXMoblieOA
//
//  Created by Mon-work on 5/9/16.
//  Copyright © 2016 YYang. All rights reserved.
//

#import "Masonry.h"
#import "MailAttachmentTableViewCell.h"
#import "CYMailUtil.h"
#import "CYAttachment.h"

typedef enum : NSUInteger {
    MailAttachmentStatusDownloaded,
    MailAttachmentStatusToDownload,
} MailAttachmentStatus;

@interface MailAttachmentTableViewCell ()

@property (nonatomic, assign) MailAttachmentStatus status;
@property (nonatomic, strong) UILabel *lbName;
@property (nonatomic, strong) UIButton *btnOperation;

@end

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
    
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(8);
        make.right.equalTo(_btnOperation.mas_left).offset(-8);
        make.top.equalTo(self.contentView.mas_top).offset(8);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-8);
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
    _lbName               = [[UILabel alloc] init];
    _lbName.numberOfLines = 3;
    _lbName.adjustsFontSizeToFitWidth = YES;
    _lbName.font = [UIFont systemFontOfSize:15];
    _lbName.minimumScaleFactor = 0.8;
    _btnOperation         = [[UIButton alloc] init];
    [_btnOperation addTarget:self action:@selector(btnOperationClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_lbName];
    [self.contentView addSubview:_btnOperation];
}

- (void)btnOperationClicked:(UIButton *)sender{
    switch (self.status) {
        case MailAttachmentStatusToDownload:{
            if (self.downloadBlock) {
                self.downloadBlock();
            }
            break;
        }
        default:{
            if (self.openBlock) {
                self.openBlock();
            }
            break;
        }
    }
}

+ (NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

#pragma mark - Accessors
- (void)setStatus:(MailAttachmentStatus)status{
    _status = status;
    if (_status == MailAttachmentStatusDownloaded) {
        [self.btnOperation setBackgroundImage:[UIImage imageNamed:ImageDownloaded] forState:UIControlStateNormal];
        [self.btnOperation setBackgroundImage:[UIImage imageNamed:ImageDownloaded] forState:UIControlStateHighlighted];
    } else {
        [self.btnOperation setBackgroundImage:[UIImage imageNamed:ImageDownload] forState:UIControlStateNormal];
        [self.btnOperation setBackgroundImage:[UIImage imageNamed:ImageDownloadHL] forState:UIControlStateHighlighted];
    }
}

- (void)setAttachment:(CYAttachment *)attachment{
    _attachment = attachment;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[CYMailUtil attachmentFolderOfMail:attachment.ownerMail] stringByAppendingPathComponent:attachment.filename];
    if(![fileManager fileExistsAtPath:filePath]){
        self.status = MailAttachmentStatusToDownload;
    }else{
        self.status = MailAttachmentStatusDownloaded;
    }
    
    self.lbName.text = attachment.filename;
}

@end
