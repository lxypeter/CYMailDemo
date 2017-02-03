//
//  MailEditViewController.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/11.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "CYBaseMailViewController.h"

typedef NS_ENUM(NSUInteger,CYMailEditType) {
    CYMailEditTypeNew,
    CYMailEditTypeReply,
    CYMailEditTypeForward,
    CYMailEditTypeSimpleForward
};

@class CYMail,CYMailAccount;
@interface MailEditViewController : CYBaseMailViewController

@property (nonatomic, strong) CYMailAccount *account;
@property (nonatomic, strong) CYMail *originMail;
@property (nonatomic, assign) CYMailEditType editType;

+ (instancetype)controllerWithAccount:(CYMailAccount *)account editType:(CYMailEditType)editType originMail:(CYMail *)originMail;

- (instancetype)initWithAccount:(CYMailAccount *)account editType:(CYMailEditType)editType originMail:(CYMail *)originMail;

@end
