//
//  MailAccountListViewController.m
//  HNPositionAsst
//
//  Created by MonW on 7/6/16.
//  Copyright © 2016 YYang. All rights reserved.
//

#import "MailHomeViewController.h"
#import "MailAccountListViewController.h"
#import "Masonry.h"
#import "MailLoginViewController.h"
#import "CYMailModelManager.h"
#import "CYMailSessionManager.h"

@interface MailAccountListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *accountTableView;
@property (nonatomic, strong) NSMutableArray<CYMailAccount *> *accounts;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation MailAccountListViewController

#pragma mark - Accessors
- (NSMutableArray *)accounts{
    if (!_accounts) {
        _accounts = [NSMutableArray array];
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
    
- (UILabel *)emptyLabel{
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.text = @"目前没有添加任何帐号";
        _emptyLabel.font = [UIFont systemFontOfSize:17];
    }
    
    return _emptyLabel;
}
    
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryMailAccount];
}

#pragma mark - setup views
- (void)configureNavigationBar {
    //添加账号按钮
    UIBarButtonItem *writeMailItem = [[UIBarButtonItem alloc]initWithTitle:@"添加账号" style:UIBarButtonItemStylePlain target:self action:@selector(clickAddAccountButton)];
    writeMailItem.tintColor = UICOLOR(@"#2D4664");
    self.navigationItem.rightBarButtonItem = writeMailItem;
}

- (void)configureSubviews {
    self.title = @"邮箱";
    [self.view addSubview:self.accountTableView];
    [self.accountTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Click Event
- (void)clickAddAccountButton {
    MailLoginViewController *ctrl = [[MailLoginViewController alloc]init];
    ctrl.accounts = self.accounts;
    [self presentViewController:ctrl animated:YES completion:nil];
}

#pragma mark - Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = self.accounts.count;
    
    if (count == 0) {
        [self.view addSubview:self.emptyLabel];
        [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
    } else {
        [self.emptyLabel removeFromSuperview];
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
    
    CYMailAccount *account = self.accounts[indexPath.row];
    cell.textLabel.text = ![NSString isBlankString:account.nickName]?account.nickName:account.username;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CYMailAccount *account = self.accounts[indexPath.row];
    [[CYMailSessionManager sharedCYMailSessionManager]registerSessionWithAccount:account];
    
    MailHomeViewController *ctrl = [[MailHomeViewController alloc] init];
    ctrl.account = account;
    [self.navigationController pushViewController:ctrl animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CYMailAccount *account = self.accounts[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.accounts removeObjectAtIndex:indexPath.row];
        
        NSError *error = nil;
        [[CYMailSessionManager sharedCYMailSessionManager]deregisterSessionWithUsername:account.username];
        BOOL result = [[CYMailModelManager sharedCYMailModelManager]deleteMailAccount:account error:&error];
        
        if (!result) {
            [self showToast:ErrorMsgCoreData];
            [self queryMailAccount];
            return;
        }
        
        [self.accountTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

#pragma mark - CoreData Method
- (void)queryMailAccount{

    NSError *error = nil;
    NSArray *mailUsers = [[CYMailModelManager sharedCYMailModelManager]allAccount:&error];
    
    if (error) {
        [self showToast:ErrorMsgCoreData];
        return;
    }
    
    self.accounts = [NSMutableArray arrayWithArray:mailUsers];
    [self.accountTableView reloadData];
    
}

@end
