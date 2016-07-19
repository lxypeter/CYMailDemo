//
//  MailHomeViewController.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/10.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailHomeViewController.h"
#import "MailListViewController.h"
#import "MailEditeViewController.h"
#import "ZTEMailUser.h"
#import "Masonry.h"
#import "ZTEMailSessionUtil.h"
#import "ZTEFolderModel.h"
#import "ZTEMailCoreDataUtil.h"

static NSString * const demoCellReuseIdentifier = @"MyToolsCellReuseIdentifier";

@interface MailHomeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *myTableView;
@property (nonatomic,strong)NSMutableArray *mailFolderArray;
@end

@implementation MailHomeViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    self.title = @"邮箱";
    [super viewDidLoad];
    [self configureSubview];
    [self loadMailFolder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self queryAllMailFolderCount];
}

#pragma mark - InitSubview
-(void)configureSubview{
    self.title = @"邮箱";
    
    //写邮件按钮
    UIBarButtonItem *writeMailItem = [[UIBarButtonItem alloc]initWithTitle:@"写邮件" style:UIBarButtonItemStylePlain target:self action:@selector(clickWriteMailButton)];
    writeMailItem.tintColor = [UIColor whiteColor];
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
    self.myTableView = tableView;
    self.myTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.myTableView.backgroundColor = UICOLOR(@"F7F8F9");
    self.myTableView.rowHeight = 60;
    
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
    
    ZTEFolderModel *folderModel = self.mailFolderArray[indexPath.row];
    NSString *name = folderModel.name;
    cell.textLabel.text = [ZTEMailSessionUtil chnNameOfFolder:name];
    
    if ([folderModel.unseenCount integerValue]!=0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",folderModel.unseenCount];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ZTEFolderModel *folderModel = self.mailFolderArray[indexPath.row];
    
    if ([folderModel.messageCount integerValue]<=0) {
        __weak typeof(self) weakSelf = self;
        [self queryMailFolderCount:folderModel success:^{
            if ([folderModel.messageCount integerValue]>0) {
                MailListViewController *ctrl = [[MailListViewController alloc]init];
                ctrl.folderModel = folderModel;
                ctrl.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ctrl animated:YES];
            }else{
                [weakSelf.view makeToast:[NSString stringWithFormat:@"【%@】为空",folderModel.name]];
            }
        } failure:^(NSError *error) {
            [weakSelf.view makeToast:[NSString stringWithFormat:@"【%@】为空",folderModel.name]];
        }];
    }else{
        MailListViewController *ctrl = [[MailListViewController alloc]init];
        ctrl.folderModel = folderModel;
        ctrl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

#pragma mark - CoreData Method
- (void)loadMailFolder{
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    // 查询
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ZTEFolderModel"];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"ownerAddress=%@",util.username];
    
    request.predicate = pre;
    
    //读取信息
    NSError *error = nil;
    NSArray *mailFolders = [coreDataContext executeFetchRequest:request error:&error];
    if (!error) {
        if(!mailFolders||mailFolders.count<=0){
            [self queryMailFolder];
        }else{
            for (ZTEFolderModel *mailFolder in mailFolders) {
                [self.mailFolderArray addObject:mailFolder];
            }
            [self sortFolderArray];
            [self.myTableView reloadData];
        }
        
    }else{
        NSLog(@"%@",error);
    }
}

#pragma mark - Network Method
- (void)queryMailFolder{
    
    __weak typeof(self) weakSelf = self;
    [self showHudWithMsg:@"邮件信箱查询中...."];
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    __weak ZTEMailSessionUtil *weakUtil = util;
    [util fetchAllFoldersSuccess:^(NSArray *folders) {
        [self hideHud];
        [weakSelf.mailFolderArray removeAllObjects];
        NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
        for (ZTESimpleFolderModel *simplefolder in folders) {
            
            ZTEFolderModel *folderModel = [NSEntityDescription insertNewObjectForEntityForName:@"ZTEFolderModel" inManagedObjectContext:coreDataContext];
            folderModel.ownerAddress = weakUtil.username;
            folderModel.name = simplefolder.name;
            folderModel.path = simplefolder.path;
            folderModel.flags = @(simplefolder.flags);
            [weakSelf.mailFolderArray addObject:folderModel];
        }
        [coreDataContext save:nil];
        [weakSelf sortFolderArray];
        [weakSelf.myTableView reloadData];
        [self queryAllMailFolderCount];
    } failure:^(NSError *error) {
        [self hideHud];
        [weakSelf.view makeToast:[NSString stringWithFormat:@"%@",error.userInfo[NSLocalizedDescriptionKey]]];
    }];
}

- (void)queryMailFolderCount:(ZTEFolderModel *)folderModel success:(void (^)())success failure:(void (^)(NSError *  error))failure{
    [self showHudWithMsg:@"请稍后..."];
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    __weak typeof(self) weakSelf = self;
    __weak ZTEFolderModel *weakModel = folderModel;
    [util folderStatusOfFolder:folderModel.path success:^(MCOIMAPFolderStatus *status) {
        [weakSelf hideHud];
        weakModel.unseenCount = @(status.unseenCount);
        weakModel.messageCount = @(status.messageCount);
        weakModel.recentCount = @(status.recentCount);
        [coreDataContext save:nil];
        success();
    } failure:^(NSError *error) {
        [weakSelf hideHud];
        failure(error);
    }];
}

- (void)queryAllMailFolderCount{
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    __weak typeof(self) weakSelf = self;
    [self.mailFolderArray enumerateObjectsUsingBlock:^(ZTEFolderModel  *_Nonnull folderModel, NSUInteger idx, BOOL * _Nonnull stop) {
        __weak ZTEFolderModel *weakModel = folderModel;
        [util folderStatusOfFolder:folderModel.path success:^(MCOIMAPFolderStatus *status) {
            weakModel.unseenCount = @(status.unseenCount);
            weakModel.messageCount = @(status.messageCount);
            weakModel.recentCount = @(status.recentCount);
            [coreDataContext save:nil];
            [weakSelf.myTableView reloadData];
        } failure:^(NSError *error) {
        }];
    }];
}

#pragma mark - Click Event
- (void)clickWriteMailButton{
    MailEditeViewController *ctrl = [[MailEditeViewController alloc]init];
    ctrl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark - Tool Method
- (void)sortFolderArray{
    [self.mailFolderArray sortUsingComparator:^NSComparisonResult(ZTEFolderModel *_Nonnull obj1, ZTEFolderModel *_Nonnull obj2) {
        
        NSComparisonResult result;
        if ([[obj1.path uppercaseString]isEqualToString:@"INBOX"]) {
            return NSOrderedAscending;
        }
        if ([[obj2.path uppercaseString]isEqualToString:@"INBOX"]) {
            return NSOrderedDescending;
        }
        result = [obj1.name compare:obj2.name];

        return result;
    }];
}

#pragma mark - Lazy Initialization
- (NSMutableArray *)mailFolderArray{
    if(!_mailFolderArray){
        _mailFolderArray = [NSMutableArray array];
    }
    return _mailFolderArray;
}

@end
