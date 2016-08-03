//
//  MailLoginViewController.h
//  HNPositionAsst
//
//  Created by Peter Lee on 16/5/30.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "ZTEBaseMailViewController.h"

@class ZTEMailUser;
@interface MailLoginViewController : ZTEBaseMailViewController

@property (nonatomic, strong) NSMutableArray<ZTEMailUser *> *accounts;

@end
