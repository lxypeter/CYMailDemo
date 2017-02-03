//
//  MailLoginViewController.h
//  HNPositionAsst
//
//  Created by Peter Lee on 16/5/30.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "CYBaseMailViewController.h"

@class CYMailAccount;
@interface MailLoginViewController : CYBaseMailViewController

@property (nonatomic, strong) NSMutableArray<CYMailAccount *> *accounts;

@end
