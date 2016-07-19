//
//  MailInputView.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/23.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailInputView : UIView
/**
 *  @author YYang, 16-03-23 15:03:45
 *
 *  回复按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
/**
 *  @author YYang, 16-03-23 15:03:13
 *
 *  查看附件
 */
@property (weak, nonatomic) IBOutlet UIButton *attachmentBtn;
/**
 *  @author YYang, 16-03-23 15:03:48
 *
 *  输入框
 */
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;

@end
