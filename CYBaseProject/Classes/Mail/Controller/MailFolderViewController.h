//
//  MailFolderViewController.h
//  GXMoblieOA
//
//  Created by YYang on 16/5/4.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "CYBaseMailViewController.h"

typedef void (^CYMoveSuccessBlock)();

@class CYMail,CYFolder;
@interface MailFolderViewController : CYBaseMailViewController

@property (nonatomic, strong) CYMail *mail;
@property (nonatomic, strong) CYFolder *folder;
@property (nonatomic, copy) CYMoveSuccessBlock moveSuccessBlock;

@end
