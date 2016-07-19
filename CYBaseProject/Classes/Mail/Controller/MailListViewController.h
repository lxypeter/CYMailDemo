//
//  MailListViewController.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/10.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "ZTEBaseMailViewController.h"

@class ZTEFolderModel;
@interface MailListViewController : ZTEBaseMailViewController

@property (nonatomic,strong) ZTEFolderModel *folderModel;

@end
