//
//  MailListCell.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/10.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZTEMailModel;
@interface MailListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *unReadImage;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *attachIconImageView;

@property (nonatomic, strong) ZTEMailModel *mailModel;

@end
