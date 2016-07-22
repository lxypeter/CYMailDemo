//
//  MailLoginViewController.m
//  HNPositionAsst
//
//  Created by Peter Lee on 16/5/30.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailLoginViewController.h"
#import "ZTEMailUser.h"
#import "ZTEMailSessionUtil.h"

@interface MailLoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;


@property (nonatomic, strong) NSDictionary *confDict;
@property (nonatomic, strong) NSArray *supportMailArray;

@end

@implementation MailLoginViewController

#pragma mark - 懒加载
- (NSArray *)supportMailArray{
    if(!_supportMailArray){
        NSString *path = [[NSBundle mainBundle]pathForResource:@"ZTESupportMail" ofType:@"plist"];
        _supportMailArray = [[NSArray alloc]initWithContentsOfFile:path];
    }
    return _supportMailArray;
}

- (NSDictionary *)confDict{
    if (!_confDict) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"ZTEMailconfiguration" ofType:@"plist"];
        _confDict = [[NSDictionary alloc]initWithContentsOfFile:path];
    }
    return _confDict;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - 点击事件
- (IBAction)clickLoginButton:(id)sender {
    
    [self.view endEditing:YES];
    
    NSString *errorMsg = nil;
    if (![self checkValidLoginErrroMessage:&errorMsg]) {
        [self.view makeToast:errorMsg];
        return;
    }
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *address = [username substringFromIndex:[username rangeOfString:@"@"].location+1];
    
    //匹配邮箱配置
    NSString *configKey;
    for (NSDictionary *dict in self.supportMailArray) {
        if ([address isEqualToString:dict[@"address"]]) {
            configKey = dict[@"configKey"];
            break;
        }
    }
    
    if ([NSString isBlankString:configKey]) {
        [self.view makeToast:[NSString stringWithFormat:@"暂不支持%@邮箱",address]];
        return;
    }
    
    NSDictionary *configDict = self.confDict[configKey];
    if (!configDict||configDict.count<=0) {
        [self.view makeToast:[NSString stringWithFormat:@"暂不支持%@邮箱",address]];
        return;
    }
    
    ZTEMailSessionUtil *sessionUtil = [ZTEMailSessionUtil shareUtil];
    [sessionUtil clear];
    sessionUtil.username = username;
    sessionUtil.password = password;
    sessionUtil.imapHostname = configDict[@"fetchMailHost"];
    sessionUtil.imapPort = [configDict[@"fetchMailPort"] integerValue];
    sessionUtil.smtpHostname = configDict[@"sendMailHost"];
    sessionUtil.smtpPort = [configDict[@"sendMailPort"] integerValue];
    sessionUtil.realname = @"";
    sessionUtil.nickname = self.nicknameTextField.text;
    if ([configDict[@"ssl"] boolValue]) {
        sessionUtil.imapConnectionType = ZTEMailConnectionTypeTLS;
    }else{
        sessionUtil.imapConnectionType = ZTEMailConnectionTypeClear;
    }
    
    [self checkMailUser];
    
}

- (IBAction)clickCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - textField代理
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.text = text;
    
    if (self.usernameTextField.text.length>0&&self.passwordTextField.text.length>0) {
        self.loginButton.enabled = YES;
        self.loginButton.alpha = 1;
    }else{
        self.loginButton.enabled = NO;
        self.loginButton.alpha = 0.5;
    }
    
    return NO;
}

#pragma mark - 调用接口
- (void)checkMailUser{
    ZTEMailSessionUtil *sessionUtil = [ZTEMailSessionUtil shareUtil];
    
    if([ZTEMailUser hasAddedAccountInfo:sessionUtil.username]){
        [self.view makeToast:@"该账号已添加！"];
        return;
    }
    
    __weak ZTEMailSessionUtil *weakSession = sessionUtil;
    [self showHudWithMsg:@"请稍后..."];
    __weak typeof(self) weakSelf = self;
    [sessionUtil checkAccountSuccess:^{
        [weakSelf hideHud];
        
        ZTEMailUser *user = [[ZTEMailUser alloc]init];
        user.username = weakSession.username;
        user.password = weakSession.password;
        user.fetchMailHost = weakSession.imapHostname;
        user.fetchMailPort = weakSession.imapPort;
        user.sendMailHost = weakSession.smtpHostname;
        user.sendMailPort = weakSession.smtpPort;
        user.realName = weakSession.realname;
        user.nickName = weakSession.nickname;
        user.ssl = (weakSession.imapConnectionType == ZTEMailConnectionTypeTLS);
        // 存储登录成功的帐号
        [ZTEMailUser storeAccountInfo:user];
        
        // 返回到选择帐户查看邮件的页面
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        [weakSession clear];
        
    } failure:^(NSError *error) {
        [weakSelf hideHud];
        [weakSelf.view makeToast:[NSString stringWithFormat:@"%@",error.userInfo[NSLocalizedDescriptionKey]]];
        [weakSession clear];
    }];
}

- (BOOL)checkValidLoginErrroMessage:(NSString **)errorMsg{
    if (self.usernameTextField.text.length <= 0) {
        *errorMsg = @"请填写邮箱帐号";
        return NO;
    }
    
    if (self.passwordTextField.text.length <= 0) {
        *errorMsg = @"请填写密码";
        return NO;
    }
    
    if (self.nicknameTextField.text.length <= 0) {
        *errorMsg = @"请填写昵称";
        return NO;
    }
    
    return YES;
}

@end
