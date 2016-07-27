//
//  MailAccountListViewController.m
//  HNPositionAsst
//
//  Created by MonW on 7/6/16.
//  Copyright © 2016 YYang. All rights reserved.
//

#import "MailHomeViewController.h"
#import "MailAccountListViewController.h"
#import "ZTEMailSessionUtil.h"
#import "ZTEMailUser.h"
#import "Masonry.h"
#import "MailLoginViewController.h"
#import "ZTEMailCoreDataUtil.h"
#import <CoreData/CoreData.h>

@interface MailAccountListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *accountTableView;
@property (nonatomic, strong) NSMutableArray<ZTEMailUser *> *accounts;
@property (nonatomic, strong) UILabel *lbPrompt;

@end

@implementation MailAccountListViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"邮箱";
    [self configureNavigationBar];
    [self configureSubviews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _accounts = nil;
    [self.accountTableView reloadData];
}

#pragma mark - setup views
- (void)configureNavigationBar{
    [self hideBackBtn];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //添加账号按钮
    UIBarButtonItem *writeMailItem = [[UIBarButtonItem alloc]initWithTitle:@"添加账号" style:UIBarButtonItemStylePlain target:self action:@selector(clickAddAccountButton)];
    writeMailItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = writeMailItem;
}

- (void)configureSubviews{
    [self.view addSubview:self.accountTableView];
    [self.accountTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Click Event
- (void)clickAddAccountButton{
    MailLoginViewController *ctrl = [[MailLoginViewController alloc]init];
    [self presentViewController:ctrl animated:YES completion:^{
        
    }];
}

#pragma mark - Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = self.accounts.count;
    
    if (count == 0) {
        [self.view addSubview:self.lbPrompt];
        [self.lbPrompt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
    } else {
        [self.lbPrompt removeFromSuperview];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ZTEMailUser *user = self.accounts[indexPath.row];
    cell.textLabel.text = [NSString isBlankString:user.nickName]?user.nickName:user.username;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ZTEMailUser *user = self.accounts[indexPath.row];
    
    ZTEMailSessionUtil *sessionUtil = [ZTEMailSessionUtil shareUtil];
    [sessionUtil clear];
    sessionUtil.username = user.username;
    sessionUtil.password = user.password;
    sessionUtil.imapHostname = user.fetchMailHost;
    sessionUtil.imapPort = user.fetchMailPort;
    sessionUtil.smtpHostname = user.sendMailHost;
    sessionUtil.smtpPort = user.sendMailPort;
    sessionUtil.realname = user.realName;
    sessionUtil.nickname = user.nickName;
    sessionUtil.smtpAuthType = user.smtpAuthType;
    if (user.ssl) {
        sessionUtil.imapConnectionType = ZTEMailConnectionTypeTLS;
    }else{
        sessionUtil.imapConnectionType = ZTEMailConnectionTypeClear;
    }
    
    MailHomeViewController *ctrl = [[MailHomeViewController alloc] init];
    [self.navigationController pushViewController:ctrl animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    ZTEMailUser *user = self.accounts[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self clearCacheWithUsername:user.username];
        [ZTEMailUser clearAccountInfo:user];
        [self.accounts removeObjectAtIndex:indexPath.row];
        [self.accountTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

#pragma mark - CoreData Method
- (void)clearCacheWithUsername:(NSString *)username{
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    //删除邮件缓存
    NSFetchRequest *mailRequest = [NSFetchRequest fetchRequestWithEntityName:@"ZTEMailModel"];
    NSPredicate *mailPre = [NSPredicate predicateWithFormat:@"ownerAddress=%@",username];
    mailRequest.predicate = mailPre;
    NSError *error = nil;
    NSArray *mails = [coreDataContext executeFetchRequest:mailRequest error:&error];
    if (!error&&mails.count>0) {
        for (id mailModel in mails) {
            [coreDataContext deleteObject:mailModel];
        }
        [coreDataContext save:nil];
    }
    
    //删除附件缓存
    NSFetchRequest *attachRequest = [NSFetchRequest fetchRequestWithEntityName:@"ZTEMailAttachment"];
    NSPredicate *attachPre = [NSPredicate predicateWithFormat:@"ownerAddress=%@",username];
    attachRequest.predicate = attachPre;
    error = nil;
    NSArray *attachs = [coreDataContext executeFetchRequest:attachRequest error:&error];
    if (!error&&attachs.count>0) {
        for (id attachModel in attachs) {
            [coreDataContext deleteObject:attachModel];
        }
        [coreDataContext save:nil];
    }
}

#pragma mark - Accessors
- (NSArray *)accounts{
    if (!_accounts) {
        _accounts = [ZTEMailUser mailAccounts];
    }
    return _accounts;
}

- (UITableView *)accountTableView{
    if (!_accountTableView) {
        _accountTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _accountTableView.rowHeight = 48.f;
        _accountTableView.delegate = self;
        _accountTableView.dataSource = self;
        _accountTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    return _accountTableView;
}

- (UILabel *)lbPrompt{
    if (!_lbPrompt) {
        _lbPrompt = [[UILabel alloc] init];
        _lbPrompt.text = @"目前没有添加任何帐号";
        _lbPrompt.font = kFont_17;
    }
    
    return _lbPrompt;
}

@end
