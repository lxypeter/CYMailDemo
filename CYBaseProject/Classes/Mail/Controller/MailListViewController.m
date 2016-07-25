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
#import "ZTEMailSessionUtil.h"
#import "ZTEMailModel.h"
#import <CoreData/CoreData.h>
#import "ZTEMailAttachment.h"
#import "ZTEMailCoreDataUtil.h"
#import "ZTEFolderModel.h"

typedef NS_ENUM(NSUInteger, MailListRefreshType){
    MailListRefreshTypeHeader,
    MailListRefreshTypeFooter
};

static const NSUInteger kpageSize = 50;

@interface MailListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) NSMutableArray <ZTEMailModel *> *dataArray;
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
    self.title = [ZTEMailSessionUtil chnNameOfFolder:self.folderModel.name];
    
    self.myTableView.estimatedRowHeight =  100;
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
    [self.myTableView registerNib:[UINib nibWithNibName:demoCellReuseIdentifier bundle:nil] forCellReuseIdentifier:demoCellReuseIdentifier];
    self.myTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.view.backgroundColor = UICOLOR(@"F7F8F9");
 
}

#pragma mark - DelegateMethod
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MailListCell *cell = [tableView dequeueReusableCellWithIdentifier:demoCellReuseIdentifier];
    [cell setMailModel:self.dataArray[indexPath.row]];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:demoCellReuseIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
        [cell setMailModel:self.dataArray[indexPath.row]];
    }];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZTEMailModel *mailModel = self.dataArray[indexPath.row];
    
    //更新邮件为已读
    [self updateMailAsSeen:mailModel];
    [self.myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    //获取邮件正文
    if ([NSString isBlankString:mailModel.content]) {
        [self showHudWithMsg:@"正在获取正文..."];
        ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
        NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
        [util getHtmlBodyWithUid:[mailModel.uid integerValue] folder:self.folderModel.path success:^(NSString *htmlBody) {
            
            [self hideHud];
            mailModel.content = htmlBody;
            [coreDataContext save:nil];
            
            MailDetailViewController *ctrl = [[MailDetailViewController alloc]init];
            ctrl.mailModel = mailModel;
            ctrl.folderModel = self.folderModel;
            [self.navigationController pushViewController:ctrl animated:YES];
            
        } failure:^(NSError *error) {
            [self hideHud];
            [self.view makeToast:@"获取正文失败"];
        }];
    }else{
        MailDetailViewController *ctrl = [[MailDetailViewController alloc]init];
        ctrl.mailModel = mailModel;
        ctrl.folderModel = self.folderModel;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    ZTEMailModel *mailModel = self.dataArray[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self deleteMailWithFolder:mailModel.folderPath uid:[mailModel.uid integerValue]];
        [coreDataContext deleteObject:mailModel];
        [coreDataContext save:nil];
        [self.myTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
}


#pragma mark - CoreData
- (void)loadMailList{
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    // 查询
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ZTEMailModel"];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"ownerAddress=%@ AND folderPath=%@",util.username,self.folderModel.path];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"receivedDate" ascending:NO];

    request.predicate = pre;
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    //读取信息
    NSError *error = nil;
    NSArray *mails = [coreDataContext executeFetchRequest:request error:&error];
    if (!error) {
        
        if (!mails||mails.count<=0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self queryMailList];
            });
        }else{
            [self.dataArray removeAllObjects];
            for (ZTEMailModel *mailModel in mails) {
                [self.dataArray addObject:mailModel];
            }
            self.myTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                NSInteger startUid = [self.folderModel.nextUid integerValue];
                [self queryMoreMailWithStartUid:startUid andLength:UINT64_MAX refreshType:MailListRefreshTypeHeader];
            }];
            self.myTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                
                NSInteger size = kpageSize -1;
                NSInteger firstUid = [self.folderModel.firstUid integerValue];
                NSInteger startUid = 1;
                if (firstUid <= size){
                    size = firstUid - 1;
                }else{
                    startUid = firstUid - kpageSize;
                }
                
                [self queryMoreMailWithStartUid:startUid andLength:size refreshType:MailListRefreshTypeFooter];
            }];
            
            [self.myTableView reloadData];
        }
        
    }else{
        NSLog(@"%@",error);
    }
}

- (void)saveMailList:(NSArray *)messages{
    
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    __weak typeof(self) weakSelf = self;
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    [messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MCOIMAPMessage  *_Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        
        ZTEMailModel *mailListModel = [NSEntityDescription insertNewObjectForEntityForName:@"ZTEMailModel" inManagedObjectContext:coreDataContext];
        
        mailListModel.ownerAddress = util.username;
        mailListModel.folderPath = weakSelf.folderModel.path;
        mailListModel.uid = @(message.uid);
        mailListModel.subject = message.header.subject;
        mailListModel.fromName = message.header.from.displayName;
        mailListModel.fromAddress = message.header.from.mailbox;
        mailListModel.sendDate = message.header.date;
        mailListModel.receivedDate = message.header.receivedDate;
        mailListModel.read = @(message.flags&MCOMessageFlagSeen);
        NSMutableString *cc = [NSMutableString string];
        NSString *dot = @"";
        for (MCOAddress *address in message.header.cc) {
            [cc appendString:dot];
            [cc appendString:address.mailbox];
            dot = @";";
        }
        mailListModel.cc = cc;
        NSMutableString *bcc = [NSMutableString string];
        dot = @"";
        for (MCOAddress *address in message.header.bcc) {
            [bcc appendString:dot];
            [bcc appendString:address.mailbox];
            dot = @";";
        }
        mailListModel.bcc = bcc;
        dot = @"";
        NSMutableString *to = [NSMutableString string];
        for (MCOAddress *address in message.header.to) {
            [to appendString:dot];
            [to appendString:address.mailbox];
            dot = @";";
        }
        mailListModel.to = to;
        NSArray *attachments = message.attachments;
        mailListModel.attachmentCount = @(attachments.count);
        for (MCOIMAPPart *attachment in attachments) {
            ZTEMailAttachment *mailAttachment = [NSEntityDescription insertNewObjectForEntityForName:@"ZTEMailAttachment" inManagedObjectContext:coreDataContext];
            mailAttachment.ownerAddress = mailListModel.ownerAddress;
            mailAttachment.uid = mailListModel.uid;
            mailAttachment.folderPath = mailListModel.folderPath;
            mailAttachment.partid = attachment.partID;
            mailAttachment.filename = attachment.filename;
        }
        
        NSError *error = nil;
        [coreDataContext save:&error];
        if (error) {
            NSLog(@"%@",error);
        }
    }];
}

- (void)updateNextUid:(NSInteger)nextUid{
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    self.folderModel.nextUid = @(nextUid);
    [coreDataContext save:nil];
}

- (void)updateFirstUid:(NSInteger)firstUid{
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    self.folderModel.firstUid = @(firstUid);
    [coreDataContext save:nil];
}

- (NSArray *)loadFolderAssist{
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ZTEFolderAssistModel"];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"ownerAddress=%@ AND folderPath=%@",util.username,self.folderModel.path];
    request.predicate = pre;
    
    return [coreDataContext executeFetchRequest:request error:nil];
}

- (void)updateMailAsSeen:(ZTEMailModel *)mailModel{
    if (![mailModel.read boolValue]) {
        NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
        [self updateMailAsSeenInServerWithUid:[mailModel.uid integerValue]];
        mailModel.read = @(YES);
        [coreDataContext save:nil];
    }
}

- (ZTEFolderModel *)loadTrashFolder{
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    // 查询
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ZTEFolderModel"];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"ownerAddress=%@",util.username];
    request.predicate = pre;
    
    //读取信息
    NSError *error = nil;
    NSArray *mailFolders = [coreDataContext executeFetchRequest:request error:&error];
    if (!error&&mailFolders.count>0) {
        for (ZTEFolderModel *folderModel in mailFolders) {
            if ([self isTrashFolder:folderModel]) {
                return folderModel;
            }
        }
    }
    return nil;
}

- (BOOL)isTrashFolder:(ZTEFolderModel *)folderModel{
    
    //根据目录标识
    BOOL flagJudgement =[folderModel.flags integerValue] & ZTEMailFolderFlagTrash;
    //根据目录名称
    BOOL nameJudgement = [folderModel.name isEqualToString:@"已删除"]||[[folderModel.name uppercaseString] isEqualToString:@"TRASH"]||[[folderModel.name uppercaseString] isEqualToString:@"JUNK"];
    
    return flagJudgement||nameJudgement;
}

#pragma mark - Network Methods
- (void)queryMailList{
    
    NSInteger size = kpageSize - 1;
    NSInteger totalCount = [self.folderModel.messageCount integerValue];
    NSInteger location = 1;
    if (totalCount <= 0){
        return;
    }else if (totalCount <= size){
        size = totalCount - 1;
    }else{
        location = totalCount - size;
    }
    
    [self showHudWithMsg:@"正在加载邮件..."];
    __weak typeof(self) weakSelf = self;
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    [util fetchMessagesWithFolder:self.folderModel.path location:location size:size success:^(NSArray *messages) {
        
        [self hideHud];
        
        [self saveMailList:messages];
        
        if (messages&&messages.count>0) {
            
            MCOIMAPMessage *lastMsg = [messages lastObject];
            [self updateNextUid:lastMsg.uid+1];
            
            MCOIMAPMessage *firstMsg = [messages firstObject];
            [self updateFirstUid:firstMsg.uid];
            
            [weakSelf loadMailList];
        }
        
    } failure:^(NSError *error) {
        [self hideHud];
        [weakSelf.view makeToast:[NSString stringWithFormat:@"%@",error.userInfo[NSLocalizedDescriptionKey]]];
    }];
}

- (void)queryMoreMailWithStartUid:(NSInteger)startUid andLength:(NSInteger)length refreshType:(MailListRefreshType)refreshType{
    
    __weak typeof(self) weakSelf = self;
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    [util fetchMessagesWithFolder:self.folderModel.path startUid:startUid length:length success:^(NSArray *messages) {
        [weakSelf.myTableView.footer endRefreshing];
        [weakSelf.myTableView.header endRefreshing];
        
        [self saveMailList:messages];
        
        if (messages&&messages.count>0) {
            
            MCOIMAPMessage *msg;
            switch (refreshType) {
                case MailListRefreshTypeHeader:{
                    msg = [messages lastObject];
                    [self updateNextUid:msg.uid+1];
                    break;
                }
                case MailListRefreshTypeFooter:{
                    msg = [messages firstObject];
                    [self updateFirstUid:msg.uid];
                    break;
                }
            }
            
            [weakSelf loadMailList];
        }
        
    } failure:^(NSError *error) {
        [weakSelf.myTableView.footer endRefreshing];
        [weakSelf.myTableView.header endRefreshing];
        [weakSelf.view makeToast:[NSString stringWithFormat:@"%@",error.userInfo[NSLocalizedDescriptionKey]]];
    }];
    
}

- (void)updateMailAsSeenInServerWithUid:(NSInteger)uid{
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    [util updateMailAsSeenWithFolder:self.folderModel.path uid:uid success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)deleteMailWithFolder:(NSString *)folder uid:(NSInteger)uid{
    
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    
    if ([self isTrashFolder:self.folderModel]) {//已在垃圾箱
        [util deleteMailWithFolder:folder uid:uid success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }else{//未在垃圾箱
        ZTEFolderModel *folderModel = [self loadTrashFolder];
        if (folderModel) {
            [util moveMessagesWithFolder:folder uid:uid destFolder:folderModel.path success:^{
                
            } failure:^(NSError *error) {
                
            }];
        }
    }
    
}

#pragma mark -Getters and Setters
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
