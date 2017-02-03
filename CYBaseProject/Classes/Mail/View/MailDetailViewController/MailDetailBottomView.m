//
//  MailDetailBottomView.m
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/21.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import "MailDetailBottomView.h"

static const CGFloat ImageViewWidth = 20.f;

@interface MailBottomButton : UIButton

@end

@implementation MailBottomButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *btnColor = UICOLOR(@"#555555");
        [self setTitleColor:btnColor forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imageW = ImageViewWidth;
    CGFloat imageH = ImageViewWidth;
    CGFloat imageX = (contentRect.size.width - imageW)/2 ;
    CGFloat imageY = 5;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, contentRect.size.height - 12 -5, contentRect.size.width, 12);
}

@end

@interface MailDetailBottomView ()

@property (nonatomic, strong) MailBottomButton *replyButton;
@property (nonatomic, strong) MailBottomButton *deleteButton;
@property (nonatomic, strong) MailBottomButton *moveButton;
@property (nonatomic, strong) MailBottomButton *attachButton;

@end

@implementation MailDetailBottomView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UICOLOR(@"#F5F5F5");
        
        CGFloat btnWidth = [UIScreen mainScreen].bounds.size.width/4;
        CGFloat btnHeight = 45;
        
        MailBottomButton *replyButton = [self generateBottomButtonWithTitle:MsgReplyNForward imageName:ImageReply frame:CGRectMake(0,0,btnWidth,btnHeight)];
        [replyButton addTarget:self action:@selector(clickReplyButton) forControlEvents:UIControlEventTouchUpInside];
        self.replyButton = replyButton;
        [self addSubview:replyButton];
        
        MailBottomButton *deleteButton = [self generateBottomButtonWithTitle:MsgDelete imageName:ImageDelete frame:CGRectMake(btnWidth,0,btnWidth,btnHeight)];
        [deleteButton addTarget:self action:@selector(clickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
        self.deleteButton = deleteButton;
        [self addSubview:deleteButton];
        
        MailBottomButton *moveButton = [self generateBottomButtonWithTitle:MsgMove imageName:ImageMove frame:CGRectMake(btnWidth*2,0,btnWidth,btnHeight)];
        [moveButton addTarget:self action:@selector(clickMoveButton) forControlEvents:UIControlEventTouchUpInside];
        self.moveButton = moveButton;
        [self addSubview:moveButton];
        
        
        MailBottomButton *attachButton = [self generateBottomButtonWithTitle:MsgAttachment imageName:ImageAttachment frame:CGRectMake(btnWidth*3,0,btnWidth,btnHeight)];
        [attachButton addTarget:self action:@selector(clickAttachmentButton) forControlEvents:UIControlEventTouchUpInside];
        attachButton.hidden = YES;
        self.attachButton = attachButton;
        [self addSubview:attachButton];
        
    }
    return self;
}

- (MailBottomButton *)generateBottomButtonWithTitle:(NSString *)title imageName:(NSString *)imageName frame:(CGRect)frame{
    MailBottomButton *btn = [[MailBottomButton alloc]initWithFrame:frame];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    return btn;
}

#pragma mark - event method
- (void)clickReplyButton{
    if (self.replyActionBlock) {
        self.replyActionBlock();
    }
}

- (void)clickDeleteButton{
    if (self.deleteActionBlock) {
        self.deleteActionBlock();
    }
}

- (void)clickMoveButton{
    if (self.moveActionBlock) {
        self.moveActionBlock();
    }
}

- (void)clickAttachmentButton{
    if (self.attachmentActionBlock) {
        self.attachmentActionBlock();
    }
}

#pragma mark - get/set method
- (void)setHasAttachment:(BOOL)hasAttachment{
    _hasAttachment = hasAttachment;
    self.attachButton.hidden = !hasAttachment;
}

@end
