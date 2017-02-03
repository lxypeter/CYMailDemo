//
//  MailLoginViewController.m
//  HNPositionAsst
//
//  Created by Peter Lee on 16/5/30.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailLoginViewController.h"
#import "CYMailSessionManager.h"
#import "CYMailModelManager.h"

@interface MailLoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;


@property (nonatomic, strong) NSDictionary *confDict;
@property (nonatomic, strong) NSArray *supportMailArray;

@end

@implementation MailLoginViewController

#pragma mark - Lazy load
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

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - event method
- (IBAction)clickLoginButton:(id)sender {
    
    [self.view endEditing:YES];
    
    NSString *errorMsg = nil;
    if (![self validInfos:&errorMsg]) {
        [self showToast:errorMsg];
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
        [self showToast:[NSString stringWithFormat:@"暂不支持%@邮箱",address]];
        return;
    }
    
    NSDictionary *configDict = self.confDict[configKey];
    if (!configDict||configDict.count<=0) {
        [self showToast:[NSString stringWithFormat:@"暂不支持%@邮箱",address]];
        return;
    }
    
    CYMailAccount *account = (CYMailAccount *)[[CYMailModelManager sharedCYMailModelManager]createManagedObjectOfClass:CYMailAccount.self];
    account.username = username;
    account.password = password;
    account.fetchHost = configDict[@"fetchMailHost"];
    account.fetchPort = configDict[@"fetchMailPort"];
    account.sendHost = configDict[@"sendMailHost"];
    account.sendPort = configDict[@"sendMailPort"];
    account.nickName = self.nicknameTextField.text;
    account.smtpAuthType = configDict[@"smtpAuthType"];
    account.ssl = configDict[@"ssl"];
    
    [self checkMailAccount:account];
    
}

- (IBAction)clickCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
- (void)checkMailAccount:(CYMailAccount *)account{
    
    CYMailSession *session = [[CYMailSessionManager sharedCYMailSessionManager]registerSessionWithAccount:account];
    
    __weak typeof(self) weakSelf = self;
    [self showHudWithMsg:@"请稍后..."];
    [session checkAccountSuccess:^{
        [weakSelf hideHuds];
        if (![[CYMailModelManager sharedCYMailModelManager]save:nil]) {
            [[CYMailSessionManager sharedCYMailSessionManager]deregisterSessionWithUsername:account.username];
            [self showToast:ErrorMsgCoreData];
            return;
        }
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        [weakSelf hideHuds];
        [weakSelf showToast:[NSString stringWithFormat:@"%@",error.userInfo[NSLocalizedDescriptionKey]]];
        [[CYMailModelManager sharedCYMailModelManager]rollback];
        [[CYMailSessionManager sharedCYMailSessionManager]deregisterSessionWithUsername:account.username];
    }];
    
}

- (BOOL)validInfos:(NSString **)errorMsg{
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
    
    for (CYMailAccount *user in self.accounts) {
        if ([user.username isEqualToString:self.usernameTextField.text]) {
            *errorMsg = @"该账号已添加";
            return NO;
        }
    }
    
    return YES;
}

@end
