//
//  MailDetailViewController.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/22.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "CYBaseMailViewController.h"



@class CYMail,CYFolder;
@interface MailDetailViewController : CYBaseMailViewController

@property (nonatomic, strong) CYFolder *folder;
@property (nonatomic, strong) CYMail *mail;

@end
