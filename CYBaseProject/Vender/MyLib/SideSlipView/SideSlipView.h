//
//  SideSlipView.h
//  LoveMarket
//
//  Created by 段晓冬 on 15/8/10.
//  Copyright (c) 2015年 ztesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

// 宏定义
// 侧滑组件的宽度
#define kSlipViewWidth ([UIScreen mainScreen].bounds.size.width * 0.8)

// 枚举定义，滑动组件样式
typedef enum SideSlipViewStyleEnum  {
    SideSlipViewStyleLeft = 0,           // 从左侧划出
    SideSlipViewStyleRight = 1,          // 从右侧划出
    SideSlipViewStyleLeftAndBlurImg = 2, // 从左侧划出并且遮挡处显示『磨砂』玻璃效果
    SideSlipViewStyleRightAndBlurImg = 3 // 从左侧划出并且遮挡处显示『磨砂』玻璃效果
} SideSlipViewStyle;

// 滑动组件导航栏按钮定义
typedef enum SideSlipHeaderStyleEnum {
    SideSlipHeaderButtonNone = 0,       // 不需要『取消』、『确定』按钮
    SideSlipHeaderButtonLeft = 1,       // 只需要『取消』按钮
    SideSlipHeaderButtonRight = 2,      // 只需要『确定』按钮
    SideSlipHeaderButtonAll = 3         // 需要『取消』、『确定』按钮，默认
} SideSlipHeaderStyle;

// 定义代理
@class SideSlipView;

@protocol SideSlipViewDelegate <NSObject>

#pragma mark - 点击取消
@optional
/**
 *  点击取消
 *
 *  @param slipView  滑动组件
 *  @param cancelBtn 取消的ButtonItem
 */
- (void)cancelBtnClickWithSideSlipView:(SideSlipView *)slipView andButtonItem:(UIBarButtonItem *)cancelBtn;

#pragma mark - 点击确定
@optional
/**
 *  点击确定
 *
 *  @param slipView 滑动组件
 *  @param okBtn    确定的ButtonItem
 */
- (void)okBtnClickWithSideSlipView:(SideSlipView *)slipView andButtonItem:(UIBarButtonItem *)okBtn;

@end

@interface SideSlipView : UIView

/**
 *  隐藏滑动组件的按钮
 */
@property (nonatomic, strong) UIButton *hideSideSlipBtn;

/**
 *  侧滑组件中要显示的内容
 */
@property (nonatomic, strong) UIView *contentView;

/**
 *  侧滑组件中显示内容的Frame
 */
@property (nonatomic, assign) CGRect contentViewFrame;

/**
 *  导航栏样式
 */
@property (nonatomic, assign) SideSlipHeaderStyle sideSlipHeaderStyle;

/**
 *  滑动组件头部的导航栏
 */
@property (strong, nonatomic) IBOutlet UINavigationBar *headerNavigationBar;

/**
 *  导航栏左侧按钮
 */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButtonItem;

/**
 *  导航栏右侧按钮
 */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButtonItem;

/**
 *  父控制器是否存在tabBar
 */
@property (nonatomic,assign) BOOL hasTabBar;

/**
 *  导航栏标题
 */
@property (nonatomic,strong) NSString *title;

/**
 *  滑动组件代理
 */
@property (nonatomic, assign) id <SideSlipViewDelegate> delegate;

#pragma mark - 导航栏左侧按钮被点击
/**
 *  导航栏左侧按钮被点击
 *
 *  @param sender 点击的UIBarButtonItem
 */
- (IBAction)leftButtonItemClick:(UIBarButtonItem *)sender;

#pragma mark - 导航栏左侧按钮被点击
/**
 *  导航栏右侧按钮被点击
 *
 *  @param sender 点击的UIBarButtonItem
 */
- (IBAction)rightButtonItemClick:(UIBarButtonItem *)sender;


#pragma mark - 初始化侧滑组件
/**
 *  初始化侧滑组件
 *
 *  @param sender 弹出侧滑组件的ControllerView
 *  @param style  侧滑组件的样式
 *
 *  @return 侧滑组件实例
 */
- (instancetype)initWithSender:(UIViewController*)sender andStyle:(SideSlipViewStyle)style;

#pragma mark - 显示侧滑组件
/**
 *  显示侧滑组件
 */
- (void)show;

#pragma mark - 隐藏侧滑组件
/**
 *  隐藏侧滑组件
 */
- (void)hide;

#pragma mark - 快捷显示/隐藏侧滑组件
/**
 *  快捷显示/隐藏侧滑组件
 */
- (void)switchMenu;

#pragma mark - 显示侧滑组件中的内容
/**
 *  显示侧滑组件中的内容
 *
 *  @param contentView 侧滑组件中要显示的内容
 */
- (void)setContentView:(UIView*)contentView;


@end
