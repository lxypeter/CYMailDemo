//
//  MailListViewController.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/10.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailListViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MailListCell.h"
#import "MailDetailViewController.h"
#import "MJRefresh.h"
#import <Masonry.h>
#import "CYMailUtil.h"
#import "CYMailModelManager.h"
#import "CYMailSessionManager.h"

typedef NS_ENUM(NSUInteger, MailListRefreshType){
    MailListRefreshTypeHeader,
    MailListRefreshTypeFooter
};

static const NSUInteger kUidRange = 100;

@interface MailListViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <CYMail *> *dataArray;
@property (nonatomic, strong, readonly) CYMailSession *session;
@end

static NSString *const demoCellReuseIdentifier = @"MailListCell";

@implementation MailListViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubview];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self loadMailList];
}

#pragma mark - InitSubviews
- (void)configureSubview{
    self.title = NSLocalizedString([self.folder.name uppercaseString], nil);;
    self.view.backgroundColor = UICOLOR(@"F7F8F9");
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self queryMailWithRefreshType:MailListRefreshTypeFooter];
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

#pragma mark - DelegateMethod
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(self.dataArray.count>0){
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self queryMailWithRefreshType:MailListRefreshTypeHeader];
            [self.session syncMailWith:self.folder success:^() {
                [tableView reloadData];
            } failure:nil];
        }];
    }
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MailListCell *cell = [tableView dequeueReusableCellWithIdentifier:demoCellReuseIdentifier];
    [cell setMail:self.dataArray[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:demoCellReuseIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
        [cell setMail:self.dataArray[indexPath.row]];
    }];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CYMail *mail = self.dataArray[indexPath.row];
    
    //更新邮件为已读
    [self.session updateMailAsSeen:mail success:nil failure:nil];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    MailDetailViewController *ctrl = [[MailDetailViewController alloc]init];
    ctrl.mail = mail;
    ctrl.folder = self.folder;
    [self.navigationController pushViewController:ctrl animated:YES];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CYMail *mail = self.dataArray[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self deleteMail:mail];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
}


#pragma mark - CoreData
- (void)loadMailList{
    
    NSError *error = nil;
    NSArray<CYMail *> *mails = [[CYMailModelManager sharedCYMailModelManager]mailsOfFolder:self.folder error:&error];
    
    if (error) {
        [self showToast:ErrorMsgCoreData];
        return;
    }
    
    if (!mails||mails.count<=0) {
        [self.tableView.mj_footer beginRefreshing];
    }else{
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:mails];
        [self.tableView reloadData];
    }
    
}

#pragma mark - Network Methods
- (void)queryMailWithRefreshType:(MailListRefreshType)refreshType{
    
    NSUInteger startUid;
    NSUInteger size;
    switch (refreshType) {
        case MailListRefreshTypeHeader:{
            startUid = [self.folder.nextUid integerValue];
            size = UINT64_MAX;
            break;
        }
        case MailListRefreshTypeFooter:{
            size = kUidRange;
            NSInteger firstUid = [self.folder.firstUid integerValue];
            if (firstUid == 0) {
                firstUid = [self.folder.nextUid integerValue];
            }
            if (firstUid <= size){
                startUid = 1;
                size = firstUid - 1;
            }else{
                startUid = firstUid - 1 - size;
            }
            break;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [self.session fetchMailsOfFolder:self.folder startUid:startUid length:size success:^(NSArray<CYMail *> *mails) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        
        if (self.dataArray.count > 0&&refreshType == MailListRefreshTypeHeader) {
            [mails enumerateObjectsUsingBlock:^(CYMail * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.dataArray insertObject:obj atIndex:0];
            }];
        }else{
            [mails enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(CYMail * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.dataArray addObject:obj];
            }];
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf showToast:[NSString stringWithFormat:@"%@",error.userInfo[NSLocalizedDescriptionKey]]];
    }];
    
}

- (void)deleteMail:(CYMail *)mail{
    
    //not concern about the feedback from server, keep operation fluent
    [self.session deleteMail:mail inFolder:self.folder success:nil failure:nil];
    
    //delete the cache
    NSError *error;
    [[CYMailModelManager sharedCYMailModelManager]deleteMail:mail error:&error];
    if(error){
        [self showToast:ErrorMsgCoreData];
    }
}

#pragma mark -Getters and Setters
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.estimatedRowHeight =  100;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView registerNib:[UINib nibWithNibName:demoCellReuseIdentifier bundle:nil] forCellReuseIdentifier:demoCellReuseIdentifier];
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (CYMailSession *)session{
    return [[CYMailSessionManager sharedCYMailSessionManager]getSessionWithUsername:self.folder.account.username];
}

@end
