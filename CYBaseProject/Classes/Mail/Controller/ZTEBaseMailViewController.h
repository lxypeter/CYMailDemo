//
//  ZTEBaseMailViewController.h
//  HNPositionAsst
//
//  Created by Peter Lee on 16/5/20.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSString *kMailUserKey = @"kMailUserKey";

#define UserDefault [NSUserDefaults standardUserDefaults]

@interface ZTEBaseMailViewController : UIViewController

/**
 *  设置导航栏后退按钮
 */
- (void) setBackBtn;

/**
 *  @author Mon
 *
 *  隐藏返回按钮
 */
- (void)hideBackBtn;

/**
 *  @author YYang, 16-01-31 15:01:14
 *
 *  设置右导航栏
 *
 *  @param title    按钮标题
 *  @param iconName 按钮图片
 */
-(void)setNavRightBtnWithTitle:(NSString *)title andIconName:(NSString *)iconName;
/**
 *  @author YYang, 16-02-01 11:02:23
 *
 *  导航栏右按钮点击事件
 */
-(void)rightBtnClicked:(UIButton *)sender;




#pragma mark - 菊花转
/**
 *  @author YYang, 16-01-31 22:01:26
 *
 *  展示普通Hud
 *
 */
- (void) showHudWithMsg:(NSString *)msg;
/**
 *  @author YYang, 16-01-31 22:01:38
 *
 *  隐藏所有Hud
 */
- (void) hideHud;

/**
 *  @author CY.Lee, 16-07-18 17:07:23
 *
 *  隐藏普通Hud
 */
- (void)hideNormalHud;

/**
 *  @author YYang, 16-05-07 17:05:45
 *
 *  下载进度
 *
 *  @param msg   上传/下载
 *  @param scale 比例
 */
- (void)showRingHUDWithMsg:(NSString *)msg andTotalSize:(long long )totalSize andTotalReaded:(long long)totalReaded;

#pragma mark - 网络

/**
 *  @author YYang, 16-04-11 11:04:26
 *
 *  隐藏tabbar
 */
- (void)hideTabBar;

/**
 *  @author YYang, 16-04-11 11:04:08
 *
 *  显示 tabBar
 */
- (void)showTabBar;


@end
