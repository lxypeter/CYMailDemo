//
//  AttachmentViewController.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/28.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "AttachmentViewController.h"
#import "YYSandBoxUtil.h"
#import "MailAttachmentTableViewCell.h"
#import "DocPreviewUtil.h"
#import "UIView+Frame.h"
#import "ZTEMailCoreDataUtil.h"
#import <CoreData/CoreData.h>
#import "ZTEMailAttachment.h"
#import "ZTEMailSessionUtil.h"

@interface AttachmentViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) UITableView *myTableVeiw;
@property (nonatomic, copy) NSString *mailAttachmentParentFolder;
@property (nonatomic, copy) NSString *mailAttachmentFolder;

@end

@implementation AttachmentViewController

#pragma mark - init method
- (instancetype)initWithOwnerAddress:(NSString *)ownerAddress folderPath:(NSString *)folderPath uid:(NSInteger)uid attachments:(NSArray<ZTEMailAttachment *> *)attachments parentController:(UIViewController *)parentController{
    self = [super init];
    if (self) {
        _ownerAddress = [ownerAddress copy];
        _folderPath = [folderPath copy];
        _uid = uid;
        _attachments = attachments;
        _parentController = parentController;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.width = 0.8 * CGRectGetWidth([UIScreen mainScreen].bounds);
    [self.view addSubview:self.myTableVeiw];
    
    // 创建存放附件的文件夹
    [YYSandBoxUtil createIfNotExistsFolder:self.mailAttachmentParentFolder];
    [YYSandBoxUtil createIfNotExistsFolder:self.mailAttachmentFolder];
}

#pragma mark - Delegate Methods
#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.attachments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MailAttachmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MailAttachmentTableViewCell reuseIdentifier]];
    
    __weak typeof(self) weakSelf = self;
    ZTEMailAttachment *attachment = weakSelf.attachments[indexPath.row];
    if (!cell) {
        cell = [[MailAttachmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MailAttachmentTableViewCell reuseIdentifier]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.operation = ^void(MailAttachmentTableViewCell *cell){
            if (cell.status == MailAttachmentStatusToDownload) {
                [weakSelf downlLoadAttachment:attachment];
            } else {
                [weakSelf openAttachment:attachment];
            }
        };
    }
    cell.lbPrefix.text = [NSString stringWithFormat:@"附件%ld", indexPath.row + 1];
    cell.lbName.text = attachment.filename;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self.mailAttachmentFolder stringByAppendingPathComponent:attachment.filename];
    if(![fileManager fileExistsAtPath:filePath]){
        cell.status = MailAttachmentStatusToDownload;
    }else{
        cell.status = MailAttachmentStatusDownloaded;
    }
    
    return cell;
}

#pragma mark - Network Methods
/**
 *  @author Mon
 *
 *  下载一个附件
 */
- (void)downlLoadAttachment:(ZTEMailAttachment *)attachment{
    
    NSString *filePath = [self.mailAttachmentFolder stringByAppendingPathComponent:attachment.filename];
    [self showHudWithMsg:@"正在下载..."];
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    [util fetchMessageAttachmentWithFolder:attachment.folderPath uid:[attachment.uid integerValue] partID:attachment.partid downloadPath:filePath success:^{
        [self hideHud];
        [self.myTableVeiw reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
        [self.myTableVeiw reloadData];
    } progress:^(NSInteger current, NSInteger maximum) {
        [self hideNormalHud];
        [self showRingHUDWithMsg:@"下载中..." andTotalSize:maximum andTotalReaded:current];
    }];
    
}

#pragma mark - Event Response
- (void)openAttachment:(ZTEMailAttachment *)attachment{
    [[DocPreviewUtil shareUtil]previewDocOfPath:[self.mailAttachmentFolder stringByAppendingPathComponent:attachment.filename] controller:self.parentController];
}

#pragma mark -Getters and Setters
- (UITableView *)myTableVeiw{
    if(!_myTableVeiw){
        _myTableVeiw  =({
            CGRect frame = CGRectMake(0, 0, 0.8 * CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
            UITableView *var =[[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
            var.showsVerticalScrollIndicator = NO;
            var.backgroundView = nil;
            var.delegate =self;
            var.dataSource  = self;
            var.rowHeight = UITableViewAutomaticDimension;
            var.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
            var.backgroundColor = UICOLOR(@"F7F8F9");
            var.rowHeight = 60;
            var;
        });
    }
    return _myTableVeiw;
}

- (NSString *)mailAttachmentParentFolder{
    if (!_mailAttachmentParentFolder) {
        _mailAttachmentParentFolder = [[YYSandBoxUtil getDocumentDirectory] stringByAppendingPathComponent:@"MailAttachment"];
    }
    return _mailAttachmentParentFolder;
}

- (NSString *)mailAttachmentFolder{
    if (!_mailAttachmentFolder) {
        _mailAttachmentFolder = [self.mailAttachmentParentFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@",self.ownerAddress,self.folderPath,@(self.uid)]];
    }
    return _mailAttachmentFolder;
}

@end
