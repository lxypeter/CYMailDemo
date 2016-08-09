//
//  MailDetailViewController.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/22.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "CYBaseMailViewController.h"

@interface MailBottomButton : UIButton

@end

@class ZTEMailModel,ZTEFolderModel;
@interface MailDetailViewController : CYBaseMailViewController

@property (nonatomic, strong) ZTEMailModel *mailModel;
@property (nonatomic, strong) ZTEFolderModel *folderModel;

@end
