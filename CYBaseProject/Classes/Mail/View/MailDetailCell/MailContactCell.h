//
//  MailContactCell.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/23.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactOneLabel;
@property (weak, nonatomic) IBOutlet UIButton *FoldBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingWithSuper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingWithBtn;

@end
