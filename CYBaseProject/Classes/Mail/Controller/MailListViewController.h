//
//  MailListViewController.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/10.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "CYBaseMailViewController.h"

@class ZTEFolderModel;
@interface MailListViewController : CYBaseMailViewController

@property (nonatomic,strong) ZTEFolderModel *folderModel;

@end
