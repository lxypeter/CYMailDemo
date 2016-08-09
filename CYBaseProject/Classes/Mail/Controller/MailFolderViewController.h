//
//  MailFolderViewController.h
//  GXMoblieOA
//
//  Created by YYang on 16/5/4.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "CYBaseMailViewController.h"

@class ZTEMailModel;
@interface MailFolderViewController : CYBaseMailViewController

@property (nonatomic, strong) ZTEMailModel *mailModel;

@end
