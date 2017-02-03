//
//  MailHomeViewController.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/10.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailHomeViewController.h"
#import "MailListViewController.h"
#import "MailEditViewController.h"
#import "Masonry.h"
#import "CYMailModelManager.h"
#import "CYMailSessionManager.h"
#import "CYMailUtil.h"

static NSString * const demoCellReuseIdentifier = @"MyToolsCellReuseIdentifier";

@interface MailHomeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray<CYFolder *> *mailFolderArray;
@end

@implementation MailHomeViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubview];
    [self loadMailFolder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self queryAllMailFolderCount];
}

#pragma mark - InitSubview
- (void)configureSubview{
    self.title = MsgMailBox;
    
    //写邮件按钮
//    UIBarButtonItem *writeMailItem = [[UIBarButtonItem alloc]initWithTitle:@"写邮件" style:UIBarButtonItemStylePlain target:self action:@selector(clickWriteMailButton)];
//    writeMailItem.tintColor = UICOLOR(@"#2D4664");
    UIButton *writeMailButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [writeMailButton setBackgroundImage:[UIImage imageNamed:ImageWriteMail] forState:UIControlStateNormal];
    [writeMailButton addTarget:self action:@selector(clickWriteMailButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *writeMailItem = [[UIBarButtonItem alloc]initWithCustomView:writeMailButton];
    self.navigationItem.rightBarButtonItem = writeMailItem;
    
    //tableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    self.tableView = tableView;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.backgroundColor = UICOLOR(@"F7F8F9");
    self.tableView.rowHeight = 60;
    
}

#pragma mark - DelegateMethod
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mailFolderArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //1.常规方式重用 cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:demoCellReuseIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:demoCellReuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    CYFolder *folder = self.mailFolderArray[indexPath.row];
    cell.textLabel.text = NSLocalizedString([folder.name uppercaseString], nil);
    
    if ([folder.unseenCount integerValue]!=0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",folder.unseenCount];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CYFolder *folder = self.mailFolderArray[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    void (^pushBlock)(CYFolder *) = ^(CYFolder *folder){
        MailListViewController *ctrl = [[MailListViewController alloc]init];
        ctrl.folder = folder;
        ctrl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ctrl animated:YES];
    };
    
    if ([folder.messageCount integerValue]<=0) {
        [self queryMailFolderCount:folder hasMessage:^{
            pushBlock(folder);
        } noMessage:^{
            [weakSelf showToast:[NSString stringWithFormat:@"【%@】为空",folder.name]];
        }];
    }else{
        pushBlock(folder);
    }
}

#pragma mark - init datas Method
- (void)loadMailFolder{
    
    if (!self.account.folders||self.account.folders.count<=0) {
        [self queryMailFolder];
    }else{
        self.mailFolderArray = [CYMailUtil sortFolders:[self.account.folders allObjects]];
        [self.tableView reloadData];
    }
}

#pragma mark - Network Method
- (void)queryMailFolder{
    
    CYMailSession *session = [[CYMailSessionManager sharedCYMailSessionManager]getSessionWithUsername:self.account.username];
    
    __weak typeof(self) weakSelf = self;
    [self showHudWithMsg:@"邮件信箱查询中...."];
    [session fetchAllFoldersSuccess:^(NSArray<CYFolder *> *folders) {
        [self hideHuds];
        self.account.folders = [NSSet setWithArray:folders];
        [[CYMailModelManager sharedCYMailModelManager]save:nil];
        weakSelf.mailFolderArray = [CYMailUtil sortFolders:folders];
        [weakSelf.tableView reloadData];
        [weakSelf queryAllMailFolderCount];
    } failure:^(NSError *error) {
        [self hideHuds];
        [weakSelf showToast:[NSString stringWithFormat:@"%@",error.userInfo[NSLocalizedDescriptionKey]]];
    }];
    
}

- (void)queryMailFolderCount:(CYFolder *)folder hasMessage:(void (^)())hasMessage noMessage:(void (^)())noMessage{
    CYMailSession *session = [[CYMailSessionManager sharedCYMailSessionManager]getSessionWithUsername:self.account.username];
    __weak CYFolder *weakFolder = folder;
    __weak typeof(self) weakSelf = self;
    [session folderStatusOfFolder:folder.path success:^(MCOIMAPFolderStatus *status) {
        weakFolder.unseenCount = @(status.unseenCount);
        weakFolder.messageCount = @(status.messageCount);
        weakFolder.recentCount = @(status.recentCount);
        if ([weakFolder.nextUid integerValue] == 0) {
            weakFolder.nextUid = @(status.uidNext);
        }
        if ([weakFolder.firstUid integerValue] == 0) {
            weakFolder.firstUid = @(status.uidNext);
        }
        [[CYMailModelManager sharedCYMailModelManager]save:nil];
        [weakSelf.tableView reloadData];
        
        if(status.messageCount>0 && hasMessage){
            hasMessage();
        }else{
            if(noMessage){
                noMessage();
            }
        }
    } failure:^(NSError *error) {
        if(noMessage){
            noMessage();
        }
    }];
}

- (void)queryAllMailFolderCount{
    __weak typeof(self) weakSelf = self;
    [self.mailFolderArray enumerateObjectsUsingBlock:^(CYFolder  *_Nonnull folder, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf queryMailFolderCount:folder hasMessage:nil noMessage:nil];
    }];
}

#pragma mark - Click Event
- (void)clickWriteMailButton{
    MailEditViewController *ctrl = [MailEditViewController controllerWithAccount:self.account editType:CYMailEditTypeNew originMail:nil];
    [self presentViewController:ctrl animated:YES completion:nil];
}

#pragma mark - Lazy Initialization
- (NSArray<CYFolder *> *)mailFolderArray{
    if(!_mailFolderArray){
        _mailFolderArray = [NSArray<CYFolder *> array];
    }
    return _mailFolderArray;
}

@end
