//
//  ZTEBaseMailViewController.h
//  HNPositionAsst
//
//  Created by Peter Lee on 16/5/20.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYBaseMailViewController : UIViewController

#pragma mark - Hud method
- (void)showHudWithMsg:(NSString *)msg;
- (void)showHudWithMsg:(NSString *)msg inView:(UIView *)view;
- (void)showProgressHudWithMsg:(NSString *)msg precentage:(CGFloat)precentage;
- (void)hideHuds;
- (void)hideMsgHud;
- (void)hideProgressHud;

#pragma mark - Toast method
- (void)showToast:(NSString *)msg;

@end
