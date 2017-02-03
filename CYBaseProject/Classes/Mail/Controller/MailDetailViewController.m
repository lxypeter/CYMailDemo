//
//  MailDetailViewController.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/22.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailDetailViewController.h"
#import "MailContactCell.h"
#import "MailAttachmentViewController.h"
#import "MailFolderViewController.h"
#import "MailEditViewController.h"
#import "YYSandBoxUtil.h"
#import "Masonry.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MailDetailBottomView.h"
#import "CYMailModelManager.h"
#import "CYMailSessionManager.h"
#import "CYMailUtil.h"

static NSString *kMailDetailCellId = @"MailContactCell";

@interface MailDetailViewController ()<UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *infosArray;
@property (nonatomic, strong) NSArray *modifyIndexPaths;
@property (nonatomic, strong) NSArray *ccArray;
@property (nonatomic, strong) NSArray *toArray;
@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, assign) CGFloat subjectHeight;
@property (nonatomic, assign) CGFloat webViewScale;

@property (nonatomic, strong) MailAttachmentViewController *attachmentVC;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIWebView *mailDetailWebView;
@property (nonatomic, strong) UIView *subjectView;
@property (nonatomic, assign) BOOL isUnfold;
@property (nonatomic, assign) BOOL isLoadingFinished;
@property (nonatomic, strong, readonly) CYMailSession *session;

@property (nonatomic, strong) MailDetailBottomView *bottomView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MailDetailViewController

#pragma mark - Life Cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    [self configureSubview];
    [self loadContent];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark - init Views
- (void)configureSubview{
    
    self.title = MsgContent;
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
        make.left.equalTo(self.view.mas_left);
        make.height.mas_equalTo(45);
    }];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomView.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
    }];
    
}

- (void)loadContent{
    if ([NSString isBlankString:self.mail.content]) {
        [self showHudWithMsg:MsgLoading];
        __weak typeof(self) weakSelf = self;
        [self.session fetchHtmlBodyWithMail:self.mail success:^(NSString *htmlBody) {
            [weakSelf hideHuds];
            [weakSelf.mailDetailWebView loadHTMLString:weakSelf.mail.content baseURL:nil];
        } failure:^(NSError *error) {
            [weakSelf hideHuds];
            [weakSelf showToast:@"获取正文失败"];
        }];
    }
}

#pragma mark - DelegateMethod
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

#pragma mark tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.isUnfold?self.infosArray.count:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MailContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kMailDetailCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setModel:self.infosArray[indexPath.row]];
    
    if (self.isUnfold&&indexPath.row == self.infosArray.count-1) {
        cell.mailAccessoryType = MailAccessoryTypeUnfold;
    }else if(!self.isUnfold&&indexPath.row == 0) {
        cell.mailAccessoryType = MailAccessoryTypeFold;
    }else {
        cell.mailAccessoryType = MailAccessoryTypeNone;
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    return [tableView fd_heightForCellWithIdentifier:kMailDetailCellId cacheByIndexPath:indexPath configuration:^(id cell) {
        [cell setModel:weakSelf.infosArray[indexPath.row]];
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return self.contentView;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.subjectView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return self.webViewHeight;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.subjectHeight;
    }
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.isUnfold = !self.isUnfold;
    
    if (self.isUnfold) {
        [self.tableView insertRowsAtIndexPaths:self.modifyIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    }else{
        [self.tableView deleteRowsAtIndexPaths:self.modifyIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark webView
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    if(self.isLoadingFinished){
        CGFloat webViewHeight =[[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"]floatValue]*self.webViewScale+30;
        CGRect newFrame = webView.frame;
        newFrame.size.height= webViewHeight;
        newFrame.size.width = [UIScreen mainScreen].bounds.size.width;
        self.webViewHeight = webViewHeight;
        self.contentView.frame= newFrame;
        
        [self.tableView reloadData];
        
        return;
    }
    
    //get body width by js
    NSString *bodyWidth= [webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollWidth"];
    CGFloat widthOfBody = [bodyWidth floatValue];
    
    //generate the html string with the new scale
    NSString *html = [self htmlAdjustWithPageWidth:widthOfBody html:self.mail.content webView:webView];
    
    self.isLoadingFinished = YES;
    
    [webView loadHTMLString:html baseURL:nil];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    if(navigationType==UIWebViewNavigationTypeLinkClicked){
        return NO;
    }else{
        return YES;
    }
}

- (NSString *)htmlAdjustWithPageWidth:(CGFloat )pageWidth html:(NSString *)html webView:(UIWebView *)webView {
    NSMutableString *str = [NSMutableString stringWithString:html];
    self.webViewScale = webView.frame.size.width/pageWidth;
    NSString *stringForReplace = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\" initial-scale=%f, minimum-scale=0.1, maximum-scale=2.0, user-scalable=yes\"></head>",self.webViewScale];
    
    NSRange range = NSMakeRange(0, str.length);
    [str replaceOccurrencesOfString:@"</head>" withString:stringForReplace options:NSLiteralSearch range:range];
    
    return str;
}

#pragma mark - Mail method
- (void)pushReply{
    MailEditViewController *ctrl = [MailEditViewController controllerWithAccount:self.folder.account editType:CYMailEditTypeReply originMail:self.mail];
    [self presentViewController:ctrl animated:YES completion:nil];
}

- (void)pushForward{
    
    if (self.mail.attachments.count>0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:MsgContainAttachments message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        __weak typeof(self) weakSelf = self;
        [alertController addAction:[UIAlertAction actionWithTitle:MsgYes style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            MailEditViewController *ctrl = [MailEditViewController controllerWithAccount:weakSelf.folder.account editType:CYMailEditTypeForward originMail:weakSelf.mail];
            [weakSelf presentViewController:ctrl animated:YES completion:nil];
            
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:MsgNo style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            MailEditViewController *ctrl = [MailEditViewController controllerWithAccount:weakSelf.folder.account editType:CYMailEditTypeSimpleForward originMail:weakSelf.mail];
            [weakSelf presentViewController:ctrl animated:YES completion:nil];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:MsgCancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        MailEditViewController *ctrl = [MailEditViewController controllerWithAccount:self.folder.account editType:CYMailEditTypeSimpleForward originMail:self.mail];
        [self presentViewController:ctrl animated:YES completion:nil];
    }
    
    
//    MailEditeViewController *edite = [[MailEditeViewController  alloc]init];
//    edite.subject = [NSString stringWithFormat:@"转发 : %@",self.mailModel.subject];
//    edite.mailModel = self.mailModel;
//    [self.navigationController pushViewController:edite animated:YES];
}

- (void)deleteMail{    
    //not concern about the feedback from server, keep operation fluent
    [self.session deleteMail:self.mail inFolder:self.folder success:nil failure:nil];
    
    //delete the cache
    NSError *error;
    [[CYMailModelManager sharedCYMailModelManager]deleteMail:self.mail error:&error];
    if(error){
        [self showToast:ErrorMsgCoreData];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -Getters and Setters
- (CGFloat)subjectHeight{
    if (_subjectHeight == 0) {
        _subjectHeight = [self.mail.subject boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-32, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]} context:nil].size.height+15;
    }
    return _subjectHeight;
}

- (NSArray *)infosArray{
    if(!_infosArray){
        NSMutableArray *infosArray = [NSMutableArray array];
        MailContactCellModel *sendModel = [[MailContactCellModel alloc]init];
        sendModel.title = [NSString stringWithFormat:@"%@:",MsgFrom];
        sendModel.content = [NSString isBlankString:self.mail.fromName]?self.mail.fromAddress:self.mail.fromName;
        [infosArray addObject:sendModel];
        
        MailContactCellModel *receiveModel = [[MailContactCellModel alloc]init];
        receiveModel.title = [NSString stringWithFormat:@"%@:",MsgTo];
        receiveModel.content = self.mail.to;
        [infosArray addObject:receiveModel];
        
        if(![NSString isBlankString:self.mail.cc]){
            MailContactCellModel *ccModel = [[MailContactCellModel alloc]init];
            ccModel.title = [NSString stringWithFormat:@"%@:",MsgCc];
            ccModel.content = self.mail.cc;
            [infosArray addObject:ccModel];
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        MailContactCellModel *dateModel = [[MailContactCellModel alloc]init];
        dateModel.title = [NSString stringWithFormat:@"%@:",MsgDate];
        dateModel.content = [formatter stringFromDate:self.mail.sendDate];
        [infosArray addObject:dateModel];
        
        _infosArray = [infosArray copy];
    }
    return _infosArray;
}

- (NSArray *)modifyIndexPaths{
    if (!_modifyIndexPaths) {
        NSMutableArray *modifyIndexPaths = [NSMutableArray array];
        for (NSInteger i=1; i<self.infosArray.count; i++) {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
            [modifyIndexPaths addObject:ip];
        }
        _modifyIndexPaths = [modifyIndexPaths copy];
    }
    return _modifyIndexPaths;
}

- (NSArray *)toArray{
    if(!_toArray){
        _toArray = [self.mail.to componentsSeparatedByString:@";"];
    }
    return _toArray;
}

- (NSArray *)ccArray{
    if(!_ccArray){
        if (![NSString isBlankString:self.mail.cc]) {
            _ccArray = [self.mail.cc componentsSeparatedByString:@";"];
        }
    }
    return _ccArray;
}

- (MailAttachmentViewController *)attachmentVC{
    if (!_attachmentVC) {
//        _attachmentVC = [[MailAttachmentViewController alloc] initWithOwnerAddress:[ZTEMailSessionUtil shareUtil].username folderPath:self.mailModel.folderPath uid:[self.mailModel.uid integerValue] attachments:self.attachments parentController:self];
    }
    return _attachmentVC;
}

- (UIWebView *)mailDetailWebView{
    if (!_mailDetailWebView) {
        _mailDetailWebView = [[UIWebView alloc]init];
        _mailDetailWebView.delegate = self;
        _mailDetailWebView.scrollView.bounces = NO;
        _mailDetailWebView.scalesPageToFit = NO;
        _mailDetailWebView.opaque = NO;
        _mailDetailWebView.backgroundColor = [UIColor clearColor];
        if (![NSString isBlankString:self.mail.content]) {
            [_mailDetailWebView loadHTMLString:self.mail.content baseURL:nil];
        }
    }
    return _mailDetailWebView;
}

- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1)];
        UIView *seperationLine = [[UIView alloc]init];
        seperationLine.backgroundColor = [UIColor darkGrayColor];
        [_contentView addSubview:seperationLine];
        [seperationLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.height.mas_equalTo(0.5);
        }];
        [_contentView addSubview:self.mailDetailWebView];
        [self.mailDetailWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(1);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.bottom.mas_equalTo(0);
        }];
    }
    return _contentView;
}

- (UIView *)subjectView{
    if (!_subjectView) {
        _subjectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.font = [UIFont systemFontOfSize:20];
        titleLabel.text = self.mail.subject;
        titleLabel.numberOfLines = 0;
        [_subjectView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.bottom.mas_equalTo(0);
        }];
    }
    return _subjectView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 25;
        [_tableView registerNib:[UINib nibWithNibName:kMailDetailCellId bundle:nil] forCellReuseIdentifier:kMailDetailCellId];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (MailDetailBottomView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[MailDetailBottomView alloc]initWithFrame:CGRectZero];
        _bottomView.hasAttachment = (self.mail.attachments.count>0);
        
        //click event
        __weak typeof(self) weakSelf = self;
        _bottomView.replyActionBlock = ^(){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:[UIAlertAction actionWithTitle:MsgReply style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf pushReply];
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:MsgForward style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf pushForward];
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:MsgCancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        };
        
        _bottomView.deleteActionBlock = ^(){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:MsgConfirmDelete preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:MsgNo style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:MsgYes style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf deleteMail];
            }]];
            
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        };
        
        _bottomView.moveActionBlock = ^(){
            MailFolderViewController *folderCtrl = [[MailFolderViewController alloc]init];
            folderCtrl.mail = weakSelf.mail;
            folderCtrl.folder = weakSelf.folder;
            folderCtrl.moveSuccessBlock = ^(){
                [weakSelf.navigationController popViewControllerAnimated:NO];
            };
            [weakSelf presentViewController:folderCtrl animated:NO completion:nil];
        };
        
        _bottomView.attachmentActionBlock = ^(){
            
            MailAttachmentViewController *attachCtrl = [[MailAttachmentViewController alloc]init];
            attachCtrl.mail = weakSelf.mail;
            [weakSelf presentViewController:attachCtrl animated:NO completion:nil];
        };
    }
    return _bottomView;
}

- (CYMailSession *)session{
    return [[CYMailSessionManager sharedCYMailSessionManager]getSessionWithUsername:self.folder.account.username];
}

@end
