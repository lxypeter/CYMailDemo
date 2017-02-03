//
//  ZTEBaseMailViewController.m
//  HNPositionAsst
//
//  Created by Peter Lee on 16/5/20.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "CYBaseMailViewController.h"
#import "JGProgressHUD.h"
#import "UIView+Toast.h"

@interface CYBaseMailViewController ()

@property (nonatomic,strong) JGProgressHUD *hud;
@property (nonatomic,strong) JGProgressHUD *prototypeHud;

@end

@implementation CYBaseMailViewController

#pragma mark - lazy load
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

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigation];
    [self configureBackButton];
}
    
- (void)configureNavigation{
    
    self.navigationController.navigationBar.translucent = NO;
    //navigationBar color
    [self.navigationController.navigationBar setBarTintColor: UICOLOR(@"#F5F5F5")];
    
    //title color
    UIColor * color = UICOLOR(@"#2D4664");
    NSDictionary * dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}
    
- (void)configureBackButton{
    
    if (self.navigationController.viewControllers.count<=1) return;
    
    UIButton *backBtn = [[UIButton alloc] init];
    [backBtn setImage:[UIImage imageNamed:ImageNaviBack] forState:UIControlStateNormal];
    backBtn.bounds = CGRectMake(0, 0, 24, 24);
    [backBtn addTarget:self action:@selector(backToLastController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
}
    
- (void)backToLastController {
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - Hud method
- (void)showHudWithMsg:(NSString *)msg{
    self.hud.textLabel.text = msg;
    [self.hud showInView:[UIApplication sharedApplication].keyWindow animated:YES];
}
    
- (void)showHudWithMsg:(NSString *)msg inView:(UIView *)view{
    self.hud.textLabel.text = msg;
    [self.hud showInView:view animated:YES];
}

- (void)showProgressHudWithMsg:(NSString *)msg precentage:(CGFloat)precentage{
    
    if (precentage>1) {
        precentage = 1;
    }else if (precentage<0) {
        precentage = 0;
    }
    
    JGProgressHUD *hud = self.prototypeHud;
    
    if(precentage != 1){
        hud.textLabel.text = msg;
        hud.indicatorView = [[JGProgressHUDRingIndicatorView alloc] initWithHUDStyle:hud.style];
        hud.layoutChangeAnimationDuration = 0.0;
        [hud setProgress:precentage animated:NO];
        
        hud.detailTextLabel.text = [NSString stringWithFormat:@"%@: %.f%% ",MsgCompleted, precentage*100];
    }else{
        hud.textLabel.text = [NSString stringWithFormat:@"%@",MsgSuccess];
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

- (void)hideHuds{
    [self hideMsgHud];
    [self hideProgressHud];
}

- (void)hideMsgHud{
    if (self.hud.isVisible) {
        [self.hud dismiss];
    }
}

- (void)hideProgressHud{
    if (self.prototypeHud.isVisible) {
        [self.prototypeHud dismiss];
    }
}

#pragma mark - Toast method
- (void)showToast:(NSString *)msg{
    [[UIApplication sharedApplication].keyWindow makeToast:msg];
}

@end
