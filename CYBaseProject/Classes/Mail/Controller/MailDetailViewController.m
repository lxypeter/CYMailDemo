//
//  MailDetailViewController.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/22.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailDetailViewController.h"
#import "MailInputView.h"
#import "SheetView.h"
#import "MailContactCell.h"
#import "MailMoreContactCell.h"
#import "AttachmentViewController.h"
#import "MailFolderViewController.h"
#import "MailEditeViewController.h"
#import "SideSlipView.h"
#import "YYSandBoxUtil.h"
#import "Masonry.h"
#import "ZTEMailSessionUtil.h"
#import "ZTEMailModel.h"
#import "ZTEMailAttachment.h"
#import "ZTEMailCoreDataUtil.h"
#import "ZTEFolderModel.h"

typedef NS_ENUM(NSUInteger,FoldButtonTag){
    FoldButtonTagFrom,
    FoldButtonTagCopy
};

static CGFloat ImageViewWidth = 20.f;

@implementation MailTopButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imageW = ImageViewWidth;
    CGFloat imageH = ImageViewWidth;
    CGFloat imageX = 5;
    CGFloat imageY = contentRect.size.height / 2 - imageH / 2;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

@end

@interface MailDetailViewController ()<SideSlipViewDelegate,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) SheetView *sv;
@property (nonatomic,strong) NSArray *cellTitles;
@property (nonatomic,strong) NSArray *ccArray;
@property (nonatomic,strong) NSArray *toArray;
@property (nonatomic, strong) NSArray<ZTEMailAttachment *> *attachments;
@property (nonatomic,assign) NSInteger rowsCount ;
@property (nonatomic,assign) BOOL isFold;
@property (nonatomic,assign) BOOL isCopyFold;
@property (nonatomic,assign) float webViewHeight;
//TODO:考虑删除
@property (nonatomic,strong) UIFont *textFont;
@property (nonatomic,strong) NSString *folderName;
@property (nonatomic,strong) SideSlipView *sideSlipView;
@property (nonatomic, strong) AttachmentViewController *attachmentVC;
@property (nonatomic, strong) UIWebView *mailDetailWebView;

@property (weak, nonatomic) IBOutlet UIView *attachmetnView;
@property (weak, nonatomic) IBOutlet UIButton *showInputBtn;//弹出回复框
@property (weak, nonatomic) IBOutlet UIButton *attachmentBtn;//弹出附件页面
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *topBtnAreaView;

@end

@implementation MailDetailViewController

#pragma mark - Life Cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    [self configureSubview];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.topBtnAreaView.contentSize = CGSizeMake(550, 0);
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.sideSlipView hide];
}

#pragma mark - init Views
- (void)configureSubview{
    
    self.rowsCount = 5;
    self.isFold = YES;
    self.isCopyFold = YES;
    self.title = @"邮件详情";
    
    //2.加载快速回复窗口
    MailInputView *input = [[NSBundle mainBundle] loadNibNamed:@"MailInputView" owner:self options:nil].lastObject;
    [input.replyBtn addTarget:self action:@selector(inputViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    [input.attachmentBtn addTarget:self action:@selector(inputViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.inputTextView = input.inputTextView;
    self.sv = [SheetView sheetViewWithContentView:input andSuperview:self.view];
    
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
    self.myTableView.estimatedRowHeight = 44.0;
    
    //附件
    [self.mailDetailWebView loadHTMLString:self.mailModel.content baseURL:nil];
    if(self.attachments.count>0){
        self.attachmetnView.hidden = NO;
    }

    //顶部按钮
    [self configureTopButtonArea];
}

- (void)configureTopButtonArea{
    
    //转发按钮
    MailTopButton *forwardBtn = [self generateTopButtonWithTitle:@"转发" imageName:@"forward_lte"];
    [forwardBtn addTarget:self action:@selector(pushForward) forControlEvents:UIControlEventTouchUpInside];
    [self.topBtnAreaView addSubview:forwardBtn];
    [forwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(10);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(80);
    }];
    
    //回复
    MailTopButton *replyBtn = [self generateTopButtonWithTitle:@"回复" imageName:@"reply_lte"];
    [replyBtn addTarget:self action:@selector(pushReply) forControlEvents:UIControlEventTouchUpInside];
    [self.topBtnAreaView addSubview:replyBtn];
    [replyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.equalTo(forwardBtn.mas_right).offset(10);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(80);
    }];
    
    //回复所有人
    MailTopButton *replyAllBtn = [self generateTopButtonWithTitle:@"回复所有人" imageName:@"reply_all_lte"];
    [replyAllBtn addTarget:self action:@selector(pushReplyAll) forControlEvents:UIControlEventTouchUpInside];
    [self.topBtnAreaView addSubview:replyAllBtn];
    [replyAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.equalTo(replyBtn.mas_right).offset(10);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(110);
    }];
    
    //删除
    MailTopButton *deleteBtn = [self generateTopButtonWithTitle:@"删除" imageName:@"delete_lte"];
    [deleteBtn addTarget:self action:@selector(deleteMail) forControlEvents:UIControlEventTouchUpInside];
    [self.topBtnAreaView addSubview:deleteBtn];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.equalTo(replyAllBtn.mas_right).offset(10);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(80);
    }];
    
    //转移文件夹
    MailTopButton *moveBtn = [self generateTopButtonWithTitle:@"转移文件夹" imageName:@"move_lte"];
    [moveBtn addTarget:self action:@selector(pushFolderChoice) forControlEvents:UIControlEventTouchUpInside];
    [self.topBtnAreaView addSubview:moveBtn];
    [moveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.equalTo(deleteBtn.mas_right).offset(10);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(110);
    }];
    
    self.topBtnAreaView.contentSize = CGSizeMake(550, 0);
}

- (MailTopButton *)generateTopButtonWithTitle:(NSString *)title imageName:(NSString *)imageName{
    UIColor *btnColor = UICOLOR(@"#555555");
    UIColor *borderColor = UICOLOR(@"#888888");
    
    MailTopButton *btn = [[MailTopButton alloc]init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setTitleColor:btnColor forState:UIControlStateNormal];
    [btn.layer setCornerRadius:3.0]; //设置矩形四个圆角半径
    [btn.layer setMasksToBounds:YES];
    [btn.layer setBorderWidth:1]; //边框宽度
    [btn.layer setBorderColor:borderColor.CGColor];
    btn.titleLabel.font = kFont_15;
    return btn;
}

#pragma mark - DelegateMethod
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

#pragma mark tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self configureCellWithIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return self.mailDetailWebView;
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
    return 0.1;
}

#pragma mark webView
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self hideHud];
    
    //控制页面宽度
    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", webView.frame.size.width];
    [webView stringByEvaluatingJavaScriptFromString:meta];

    //获取页面高度
    CGFloat webViewHeight =[[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"]floatValue]+30;
    CGRect newFrame = webView.frame;
    newFrame.size.height= webViewHeight;
    newFrame.size.width = [UIScreen mainScreen].bounds.size.width;
    self.webViewHeight = webViewHeight;
    webView.frame= newFrame;
    
    [self.myTableView reloadData];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //判断是否是点击链接,禁止跳转
    if(navigationType==UIWebViewNavigationTypeLinkClicked){
        return NO;
    }else{
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self showHudWithMsg:@"正在加载请稍后..."];
}

#pragma mark - Private Methods
//折叠 contact
- (void)foldCell:(NSUInteger)btnTag{
    if (btnTag == FoldButtonTagCopy) {
        self.isCopyFold = !self.isCopyFold;
    }else if (btnTag == FoldButtonTagFrom) {
        self.isFold = !self.isFold;
    }
    
    int count = 5;
    if(!self.isCopyFold&&!self.isFold){
        count = 7;
    }else if (self.isCopyFold==!self.isFold){
        count = 6;
    }
    
    self.rowsCount = count;
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (UITableViewCell *)configureCellWithIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row <3){
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"null0"];
        cell.textLabel.text = self.cellTitles[indexPath.row];
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.minimumScaleFactor = 0.8;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = kFont_15;
        switch (indexPath.row) {
            case 0:{
                cell.detailTextLabel.text = self.mailModel.subject;
                break;
            }
            case 1:{
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
                cell.detailTextLabel.text = [formatter stringFromDate:self.mailModel.receivedDate];
                cell.detailTextLabel.textColor = UICOLOR(@"#b0b0b0");
                break;
            }
            case 2:
                cell.detailTextLabel.text = self.mailModel.fromName;
                cell.detailTextLabel.textColor = [UIColor colorWithRed:0.114 green:0.600 blue:0.902 alpha:1.000];
                break;
                
            default:
                break;
        }
        return cell;
        
    }
    else if(indexPath.row == 3){//收件人
        MailContactCell*cell = (MailContactCell*)([[[NSBundle mainBundle]loadNibNamed:@"MailContactCell" owner:nil options:nil]lastObject]);
        
        cell.contactOneLabel.text = self.toArray[0];
        
        self.isFold ?[cell.FoldBtn setSelected:NO] : [cell.FoldBtn setSelected:YES];
        cell.FoldBtn.tag = FoldButtonTagFrom;
        self.toArray.count >1?
        [cell.FoldBtn addTarget:self action:@selector(FoldBtnClicked:) forControlEvents:UIControlEventTouchUpInside] : [cell.FoldBtn setHidden:YES];
        cell.trailingWithBtn.priority = self.toArray.count >1?752:750;
        self.textFont = cell.contactOneLabel.font;
        return cell;
    }
    else if(indexPath.row == 4){//抄送人/收件人详情
        
        if (!self.isFold) {
            MailMoreContactCell *cell = [[MailMoreContactCell alloc]initWithDataSource:self.toArray andTextFont:self.textFont];
            return cell;
        }
        
        MailContactCell *cell = (MailContactCell*)([[[NSBundle mainBundle]loadNibNamed:@"MailContactCell" owner:nil options:nil]lastObject]);
        cell.titleLabel.text = @"抄送人:";
        cell.contactOneLabel.text = self.ccArray.count>0?self.ccArray[0]:@"";
        
        self.isCopyFold ?[cell.FoldBtn setSelected:NO] : [cell.FoldBtn setSelected:YES];
        cell.FoldBtn.tag = FoldButtonTagCopy;
        self.ccArray.count >1?
        [cell.FoldBtn addTarget:self action:@selector(FoldBtnClicked:) forControlEvents:UIControlEventTouchUpInside] : [cell.FoldBtn setHidden:YES];
        cell.trailingWithBtn.priority = self.ccArray.count >1?752:750;
        self.textFont = cell.contactOneLabel.font;
        return cell;
    }
    else if(indexPath.row == 5){//抄送人/抄送人详情
        
        if (self.isFold&&!self.isCopyFold) {
            MailMoreContactCell *cell = [[MailMoreContactCell alloc]initWithDataSource:self.ccArray andTextFont:self.textFont];
            return cell;
        }
        
        MailContactCell*cell = (MailContactCell*)([[[NSBundle mainBundle]loadNibNamed:@"MailContactCell" owner:nil options:nil]lastObject]);
        cell.titleLabel.text = @"抄送人:";
        cell.contactOneLabel.text = self.ccArray.count>0?self.ccArray[0]:@"";
        
        self.isCopyFold ?[cell.FoldBtn setSelected:NO] : [cell.FoldBtn setSelected:YES];
        cell.FoldBtn.tag = FoldButtonTagCopy;
        self.ccArray.count >1?
        [cell.FoldBtn addTarget:self action:@selector(FoldBtnClicked:) forControlEvents:UIControlEventTouchUpInside] : [cell.FoldBtn setHidden:YES];
        cell.trailingWithBtn.priority = self.ccArray.count >1?752:750;
        self.textFont = cell.contactOneLabel.font;
        return cell;
    }else{
        MailMoreContactCell *cell = [[MailMoreContactCell alloc]initWithDataSource:self.ccArray andTextFont:self.textFont];
        return cell;
    }
}

- (BOOL)isTrashFolder:(ZTEFolderModel *)folderModel{
    
    //根据目录标识
    BOOL flagJudgement =[folderModel.flags integerValue] & ZTEMailFolderFlagTrash;
    //根据目录名称
    BOOL nameJudgement = [folderModel.name isEqualToString:@"已删除"]||[[folderModel.name uppercaseString] isEqualToString:@"TRASH"]||[[folderModel.name uppercaseString] isEqualToString:@"JUNK"];
    
    return flagJudgement||nameJudgement;
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

#pragma mark - 邮件操作
- (void)pushFolderChoice{
    MailFolderViewController *folder = [[MailFolderViewController alloc]init];
    folder.mailModel = self.mailModel;
    [self.navigationController pushViewController:folder animated:YES];
}

- (void)pushReply{
    MailEditeViewController *edite = [[MailEditeViewController  alloc]init];
    edite.subject = [NSString stringWithFormat:@"回复 : %@",self.mailModel.subject];
    edite.to = [NSString stringWithFormat:@"%@,", self.mailModel.fromAddress];
    edite.mailModel = self.mailModel;
    [self.navigationController pushViewController:edite animated:YES];
}

- (void)pushReplyAll{
    MailEditeViewController *edite = [[MailEditeViewController  alloc]init];
    edite.subject = [NSString stringWithFormat:@"回复 : %@",self.mailModel.subject];
    edite.to = [NSString stringWithFormat:@"%@,", self.mailModel.fromAddress];
    edite.cc = [NSString stringWithFormat:@"%@,", self.mailModel.cc];
    [self.navigationController pushViewController:edite animated:YES];
}

- (void)pushForward{
    MailEditeViewController *edite = [[MailEditeViewController  alloc]init];
    edite.subject = [NSString stringWithFormat:@"转发 : %@",self.mailModel.subject];
    edite.mailModel = self.mailModel;
    [self.navigationController pushViewController:edite animated:YES];
}

- (void)deleteMail{
    NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
    [self deleteMailWithFolder:self.mailModel.folderPath uid:[self.mailModel.uid integerValue]];
    [coreDataContext deleteObject:self.mailModel];
    [coreDataContext save:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendMail{
    NSMutableArray *toArrs =(NSMutableArray *) [self.mailModel.to componentsSeparatedByString:@","] ;
    [toArrs enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSString isBlankString:obj]) {
            [toArrs removeObject:obj];
        }
    }];
    
    NSString *folder;
    NSInteger uid;
    if (self.mailModel) {
        folder = self.mailModel.folderPath;
        uid = [self.mailModel.uid integerValue];
    }
    
    NSString *subject = [NSString stringWithFormat:@"回复：%@",self.mailModel.subject];
    
    [self showHudWithMsg:@"正在发送..."];
    __weak typeof(self) weakSelf = self;
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    [util sendMailWithSubject:subject content:self.inputTextView.text toArray:toArrs ccArray:@[] bccArray:@[] imageAttachmentArray:@[] uid:uid folder:folder success:^{
        
        [self hideHud];
        
        [[UIApplication sharedApplication].keyWindow makeToast:@"发送邮件成功"];
        
        [weakSelf.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:NSClassFromString(@"MailHomeViewController")]){
                [weakSelf.navigationController popToViewController:obj animated:YES];
                *stop = YES;
            }
        }];
        
    } failure:^(NSError *error) {
        [self hideHud];
        [weakSelf.view makeToast:[NSString stringWithFormat:@"%@",error.userInfo[NSLocalizedDescriptionKey]]];
    } progress:^(NSInteger current, NSInteger maximum) {
        [self hideNormalHud];
        [self showRingHUDWithMsg:@"发送中..." andTotalSize:maximum andTotalReaded:current];
    }];
}

#pragma mark - Network method
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


#pragma mark - Event Response
//弹出附件
- (IBAction)attachmentBtnClicked:(UIButton *)sender {
    
    [self.sideSlipView removeFromSuperview];
    [self.sideSlipView.hideSideSlipBtn removeFromSuperview];
    
    [self.view addSubview:self.sideSlipView];
    [self.view addSubview:self.sideSlipView.hideSideSlipBtn];
    [self.sideSlipView show];
}

//弹出回复框
- (IBAction)showInputBtnClicked:(UIButton *)sender {
    [self.sv showActionSheet];
}

//弹出框
- (void)inputViewClicked:(UIButton *)sender{
    if([NSString isBlankString: self.inputTextView.text]){
        [self.view makeToast:@"请输入回复内容!"];
        return;
    }
    [self.view endEditing:YES];
    [self sendMail];
}

//折叠联系人
- (void)FoldBtnClicked:(UIButton *)sender{
    [self foldCell:sender.tag];
}

#pragma mark -Getters and Setters
- (NSArray *)cellTitles{
    if(!_cellTitles){
        _cellTitles = @[@"主    题:",@"日    期:",@"发件人:"];
    }
    return _cellTitles;
}

- (NSArray *)toArray{
    if(!_toArray){
        _toArray = [self.mailModel.to componentsSeparatedByString:@";"];
    }
    return _toArray;
}

- (NSArray *)ccArray{
    if(!_ccArray){
        if (![NSString isBlankString:self.mailModel.cc]) {
            _ccArray = [self.mailModel.cc componentsSeparatedByString:@";"];
        }
    }
    return _ccArray;
}

- (SideSlipView *)sideSlipView{
    if (!_sideSlipView) {
        _sideSlipView = [[SideSlipView alloc]initWithSender:self andStyle:SideSlipViewStyleRight];
        
        // 设置滑动组件背景
        _sideSlipView.backgroundColor = [UIColor whiteColor];
        // 设置滑动组件导航栏样式
        _sideSlipView.sideSlipHeaderStyle = SideSlipHeaderButtonNone;
        // 设置代理
        _sideSlipView.delegate = self;
        [_sideSlipView setContentView:self.attachmentVC.view];
        _sideSlipView.title = @"附件";
    }
    return _sideSlipView;
}

- (AttachmentViewController *)attachmentVC{
    if (!_attachmentVC) {
        _attachmentVC = [[AttachmentViewController alloc] initWithOwnerAddress:[ZTEMailSessionUtil shareUtil].username folderPath:self.mailModel.folderPath uid:[self.mailModel.uid integerValue] attachments:self.attachments parentController:self];
    }
    return _attachmentVC;
}

- (NSArray *)attachments{
    
    if (!_attachments) {
        NSManagedObjectContext *coreDataContext = [ZTEMailCoreDataUtil shareContext];
        // 查询
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ZTEMailAttachment"];
        
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"ownerAddress=%@ AND folderPath=%@ AND uid=%@",self.mailModel.ownerAddress,self.mailModel.folderPath,self.mailModel.uid];
        
        request.predicate = pre;
        
        //读取信息
        NSError *error = nil;
        NSArray *attachments = [coreDataContext executeFetchRequest:request error:&error];
        if (!error) {
            if (attachments) {
                _attachments = attachments;
            }else{
                _attachments = @[];
            }
        }else{
            _attachments = @[];
        }
    }
    return _attachments;
    
}

- (UIWebView *)mailDetailWebView{
    if (!_mailDetailWebView) {
        _mailDetailWebView = [[UIWebView alloc]init];
        _mailDetailWebView.delegate = self;
        _mailDetailWebView.scrollView.bounces = NO;
    }
    return _mailDetailWebView;
}

@end
