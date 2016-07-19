//
//  ZTEBaseMailViewController.m
//  HNPositionAsst
//
//  Created by Peter Lee on 16/5/20.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "ZTEBaseMailViewController.h"
#import "JGProgressHUD.h"

@interface ZTEBaseMailViewController ()

@property (nonatomic,strong) JGProgressHUD *hud;
@property (nonatomic,strong) JGProgressHUD *prototypeHUD;

@end

@implementation ZTEBaseMailViewController


#pragma mark - 懒加载
-(JGProgressHUD *)hud{
    if (!_hud) {
        _hud = [[JGProgressHUD alloc]initWithStyle:JGProgressHUDStyleDark];
        
    }
    return _hud;
}

- (JGProgressHUD *)prototypeHUD {
    if (!_prototypeHUD) {
        _prototypeHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
        _prototypeHUD.interactionType = JGProgressHUDInteractionTypeBlockNoTouches;
    }
    return _prototypeHUD;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    //设置导航栏颜色
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.133 green:0.643 blue:0.933 alpha:0.837]] forBarMetrics:UIBarMetricsDefault];
    
    //清除边框，设置一张空的图片
    //    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init]];
    
    
    //设置标题颜色
    UIColor * color = [UIColor whiteColor];
    
    NSDictionary * dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    
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
-(void)setBackBtn
{
    
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
-(void)setNavRightBtnWithTitle:(NSString *)title andIconName:(NSString *)iconName
{
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
    //    UIBarButtonItem *bb = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(rightBtnClicked)];
    rightItem.style = UIBarButtonItemStyleDone;
    self.navigationItem.rightBarButtonItem = rightItem;
    
}


- (void) backToLastController {
    
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
    if (self.prototypeHUD.isVisible) {
        [self.prototypeHUD dismiss];
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
    
    JGProgressHUD *HUD = self.prototypeHUD;
    
    double progress = totalReaded *1.0/totalSize;
    
    if(totalReaded != totalSize){
        HUD.textLabel.text = msg;
        HUD.indicatorView = [[JGProgressHUDRingIndicatorView alloc] initWithHUDStyle:HUD.style];
        HUD.layoutChangeAnimationDuration = 0.0;
        [HUD setProgress:progress animated:NO];
        HUD.detailTextLabel.text = [NSString stringWithFormat:@"已完成: %.f%% ", progress*100];
    }
    else
    {
        HUD.textLabel.text = @"Success";
        HUD.detailTextLabel.text = nil;
        HUD.layoutChangeAnimationDuration = 0.3;
        HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [HUD dismiss];
        });
    }
    
    if (!HUD.isVisible) {
        [HUD showInView:self.view];
    }
    
}

-(void)hideTabBar
{
    self . tabBarController . tabBar . hidden = YES ;
    self.hidesBottomBarWhenPushed=YES;
}

-(void)showTabBar
{
    self . tabBarController . tabBar . hidden = NO ;
    
}

-(UIImage*)imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
