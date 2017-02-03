//
//  MailHomeViewController.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/10.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "CYBaseMailViewController.h"

@class CYMailAccount;

@interface MailHomeViewController : CYBaseMailViewController

@property (nonatomic, strong) CYMailAccount *account;

@end
