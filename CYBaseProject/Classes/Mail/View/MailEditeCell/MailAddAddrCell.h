//
//  MailAddAddrCell.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/11.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YYTextView;
@interface MailAddAddrCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet YYTextView *inputView;
@property (weak, nonatomic) IBOutlet UIButton *addAddrBtn;

@end
