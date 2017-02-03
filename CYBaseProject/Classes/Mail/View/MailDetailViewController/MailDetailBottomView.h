//
//  MailDetailBottomView.h
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/21.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CYBottomViewAction)();

@interface MailDetailBottomView : UIView

@property (nonatomic, assign) BOOL hasAttachment;
@property (nonatomic, copy) CYBottomViewAction replyActionBlock;
@property (nonatomic, copy) CYBottomViewAction deleteActionBlock;
@property (nonatomic, copy) CYBottomViewAction moveActionBlock;
@property (nonatomic, copy) CYBottomViewAction attachmentActionBlock;

@end
