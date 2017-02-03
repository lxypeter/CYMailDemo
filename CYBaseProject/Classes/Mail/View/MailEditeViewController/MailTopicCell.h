//
//  MailTopicCell.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/11.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CYMailAttachBlock)();

@interface MailTopicCell : UITableViewCell

@property (nonatomic, copy) CYMailAttachBlock attachBlock;
@property (nonatomic, copy) NSString *content;

@end
