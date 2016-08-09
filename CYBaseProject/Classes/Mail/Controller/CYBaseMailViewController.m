//
//  ZTEBaseMailViewController.m
//  HNPositionAsst
//
//  Created by Peter Lee on 16/5/20.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "CYBaseMailViewController.h"
#import "JGProgressHUD.h"

@interface CYBaseMailViewController ()

@property (nonatomic,strong) JGProgressHUD *hud;
@property (nonatomic,strong) JGProgressHUD *prototypeHud;

@end

@implementation CYBaseMailViewController


#pragma mark - 懒加载
- (JGProgressHUD *)hud{
    if (!_hud) {
        _hud = [[JGProgressHUD alloc]initWithStyle:JGProgressHUDStyleDark];
    }
    return _hud;
}

- (JGProgressHUD *)prototypeHud{
    if (!_prototypeHud){
        _prototypeHud = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
        _prototypeHud.interactionType = JGProgressHUDInteractionTypeBlockNoTouches;
    }
    return _prototypeHud;
}

#pragma mark - 生命周期
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    //设置导航栏颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.133 green:0.643 blue:0.933 alpha:0.837];
    
    //设置标题颜色
    UIColor *color = [UIColor whiteColor];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.size.width = kAppBounds.size.width;
    self.navigationController.navigationBar.frame = frame;
    
    //xy从导航栏开始计算
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setBackBtn];
    
}

#pragma mark - 导航栏
#pragma mark -创建后退按钮
-(void)setBackBtn{
    
    // 设置左边按钮
    UIButton *backBtn = [[UIButton alloc] init];
    [backBtn setImage:[UIImage imageNamed:@"button_topbar_left_nor"] forState:UIControlStateNormal];
    backBtn.bounds = CGRectMake(0, 0, 10, 18);
    
    // 左边按钮添加监听事件并添加至导航栏中
    [backBtn addTarget:self action:@selector(backToLastController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
}

//导航栏右按钮
- (void)setNavRightBtnWithTitle:(NSString *)title andIconName:(NSString *)iconName{
    //右边按钮
    UIButton *rightBtn = [[UIButton alloc]init];
    [rightBtn setTitle:title forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    [rightBtn setFrame:CGRectMake(0, 0, 30, 30)];
    [rightBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    //添加到导航栏
    [rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    rightItem.style = UIBarButtonItemStyleDone;
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

//导航栏右按钮点击事件
- (void)rightBtnClicked:(UIButton *)sender{}

- (void)backToLastController {
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - Hud方法
- (void)showHudWithMsg:(NSString *)msg{
    self.hud.textLabel.text = msg;
    [self.hud showInView:self.view animated:YES];
}

- (void)hideHud{
    if (self.hud.isVisible) {
        [self.hud dismiss];
    }
    if (self.prototypeHud.isVisible) {
        [self.prototypeHud dismiss];
    }
}

- (void)hideNormalHud{
    if (self.hud.isVisible) {
        [self.hud dismiss];
    }
}

- (void)hideBackBtn{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)showRingHUDWithMsg:(NSString *)msg andTotalSize:(long long )totalSize andTotalReaded:(long long)totalReaded {
    
    JGProgressHUD *hud = self.prototypeHud;
    
    double progress = totalReaded *1.0/totalSize;
    
    if(totalReaded != totalSize){
        hud.textLabel.text = msg;
        hud.indicatorView = [[JGProgressHUDRingIndicatorView alloc] initWithHUDStyle:hud.style];
        hud.layoutChangeAnimationDuration = 0.0;
        [hud setProgress:progress animated:NO];
        hud.detailTextLabel.text = [NSString stringWithFormat:@"已完成: %.f%% ", progress*100];
    }else{
        hud.textLabel.text = @"Success";
        hud.detailTextLabel.text = nil;
        hud.layoutChangeAnimationDuration = 0.3;
        hud.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud dismiss];
        });
    }
    
    if (!hud.isVisible){
        [hud showInView:self.view];
    }
    
}

-(void)hideTabBar{
    self.tabBarController.tabBar.hidden = YES;
    self.hidesBottomBarWhenPushed=YES;
}

-(void)showTabBar{
    self.tabBarController.tabBar.hidden = NO;
}

@end
