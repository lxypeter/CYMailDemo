//
//  MailFolderViewController.m
//  GXMoblieOA
//
//  Created by YYang on 16/5/4.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailFolderViewController.h"
#import "ZTEMailSessionUtil.h"
#import "ZTEMailCoreDataUtil.h"
#import "ZTEFolderModel.h"
#import "ZTEMailModel.h"

static NSString *const reuseableID = @"MailFolderCell";

@interface MailFolderViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSIndexPath *selectedIndex;
@end

@implementation MailFolderViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubviews];
    [self loadMailFolder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)configureSubviews
{
    self.title = @"选择文件夹";
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    self.myTableView.rowHeight =  44;
    self.myTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];

    self.myTableView.backgroundColor = UICOLOR(@"F7F8F9");
}

#pragma mark - Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell= [tableView dequeueReusableCellWithIdentifier:reuseableID];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseableID];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    ZTEFolderModel *mailFolder = self.dataArray[indexPath.row];
    
    cell.textLabel.text = [ZTEMailSessionUtil chnNameOfFolder:mailFolder.name];
    
    if (self.selectedIndex == indexPath) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath;
    [tableView reloadData];
}

#pragma mark - Event Response
- (IBAction)confirmBtnClicked:(UIButton *)sender {
    if(!self.selectedIndex){
        [self.view makeToast:@"请先选择需要移动邮件至哪个文件夹!"];
        return;
    }
    [self moveFolder];
}

#pragma mark - Network Methods
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

        for (ZTEFolderModel *mailFolder in mailFolders) {
            if(![self.mailModel.folderPath isEqualToString:mailFolder.path]){
                [self.dataArray addObject:mailFolder];
            }
        }
        [self sortFolderArray];
        [self.myTableView reloadData];
        
    }else{
        NSLog(@"%@",error);
    }
}

- (void)moveFolder{
    [self showHudWithMsg:@"邮件移动中...."];
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    ZTEFolderModel *mailFolder = self.dataArray[self.selectedIndex.row];
    __weak typeof(self) weakSelf = self;
    [util moveMessagesWithFolder:self.mailModel.folderPath uid:[self.mailModel.uid integerValue] destFolder:mailFolder.path success:^{
        [self hideHud];
        [coreDataContext deleteObject:self.mailModel];
        [coreDataContext save:nil];
        [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:NSClassFromString(@"MailHomeViewController")]){
                [self.navigationController popToViewController:obj animated:YES];
                *stop = YES;
            }
        }];
    } failure:^(NSError *error) {
        [self hideHud];
        [weakSelf.view makeToast:[NSString stringWithFormat:@"%@",error.userInfo[NSLocalizedDescriptionKey]]];
    }];
}

#pragma mark - Tool Method
- (void)sortFolderArray{
    [self.dataArray sortUsingComparator:^NSComparisonResult(ZTEFolderModel *_Nonnull obj1, ZTEFolderModel *_Nonnull obj2) {
        
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

#pragma mark -Getters and Setters
- (NSMutableArray *)dataArray{
    if(!_dataArray)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
