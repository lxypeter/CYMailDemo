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
#import "UITableView+FDTemplateLayoutCell.h"

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

static NSString *kMailDetailCellId = @"MailContactCell";

@interface MailDetailViewController ()<SideSlipViewDelegate,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) SheetView *sv;
@property (nonatomic, strong) NSArray *infosArray;
@property (nonatomic, strong) NSArray *modifyIndexPaths;
@property (nonatomic, strong) NSArray *ccArray;
@property (nonatomic, strong) NSArray *toArray;
@property (nonatomic, strong) NSArray<ZTEMailAttachment *> *attachments;
@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, assign) CGFloat subjectHeight;
@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) SideSlipView *sideSlipView;
@property (nonatomic, strong) AttachmentViewController *attachmentVC;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIWebView *mailDetailWebView;
@property (nonatomic, strong) UIView *subjectView;
@property (nonatomic, assign) BOOL isUnfold;

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
    
    self.title = @"邮件详情";
    
    //2.加载快速回复窗口
    MailInputView *input = [[NSBundle mainBundle] loadNibNamed:@"MailInputView" owner:self options:nil].lastObject;
    [input.replyBtn addTarget:self action:@selector(inputViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    [input.attachmentBtn addTarget:self action:@selector(inputViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.inputTextView = input.inputTextView;
    self.sv = [SheetView sheetViewWithContentView:input andSuperview:self.view];
    
    self.subjectHeight = [self.mailModel.subject boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-32, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kFont_20} context:nil].size.height+5;
    
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
    self.myTableView.estimatedRowHeight = 25;
    [self.myTableView registerNib:[UINib nibWithNibName:kMailDetailCellId bundle:nil] forCellReuseIdentifier:kMailDetailCellId];
    self.myTableView.backgroundColor = [UIColor whiteColor];
    
    //附件
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
    return self.isUnfold?self.infosArray.count:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MailContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kMailDetailCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setModel:self.infosArray[indexPath.row]];
    
    if (self.isUnfold) {
        if(indexPath.row == self.infosArray.count-1){
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20*6/7)];
            imageView.image = [UIImage imageNamed:@"M_Fold"];
            cell.accessoryView = imageView;
        }else{
            cell.accessoryView = nil;
        }
    }else{
        if(indexPath.row == 0){
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20*6/7)];
            imageView.image = [UIImage imageNamed:@"M_Unfold"];
            cell.accessoryView = imageView;
        }else{
            cell.accessoryView = nil;
        }
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
        return self.footerView;
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
        [self.myTableView insertRowsAtIndexPaths:self.modifyIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    }else{
        [self.myTableView deleteRowsAtIndexPaths:self.modifyIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
    }
    
    [self.myTableView reloadData];
}

#pragma mark webView
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self hideHud];
    
    //控制页面宽度
    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", [UIScreen mainScreen].bounds.size.width - 32];
    [webView stringByEvaluatingJavaScriptFromString:meta];

    //获取页面高度
    CGFloat webViewHeight =[[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"]floatValue]+30;
    CGRect newFrame = webView.frame;
    newFrame.size.height= webViewHeight;
    newFrame.size.width = [UIScreen mainScreen].bounds.size.width;
    self.webViewHeight = webViewHeight;
    self.footerView.frame= newFrame;
    
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

#pragma mark -Getters and Setters
- (NSArray *)infosArray{
    if(!_infosArray){
        NSMutableArray *infosArray = [NSMutableArray array];
        MailContactCellModel *sendModel = [[MailContactCellModel alloc]init];
        sendModel.title = @"发件人：";
        sendModel.content = [NSString isBlankString:self.mailModel.fromName]?self.mailModel.fromAddress:self.mailModel.fromName;
        [infosArray addObject:sendModel];
        
        MailContactCellModel *receiveModel = [[MailContactCellModel alloc]init];
        receiveModel.title = @"收件人：";
        receiveModel.content = self.mailModel.to;
        [infosArray addObject:receiveModel];
        
        if(![NSString isBlankString:self.mailModel.cc]){
            MailContactCellModel *ccModel = [[MailContactCellModel alloc]init];
            ccModel.title = @"抄送人：";
            ccModel.content = self.mailModel.cc;
            [infosArray addObject:ccModel];
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        MailContactCellModel *dateModel = [[MailContactCellModel alloc]init];
        dateModel.title = @"时间：";
        dateModel.content = [formatter stringFromDate:self.mailModel.receivedDate];
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
        [_mailDetailWebView loadHTMLString:self.mailModel.content baseURL:nil];
    }
    return _mailDetailWebView;
}

- (UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1)];
        UIView *seperationLine = [[UIView alloc]init];
        seperationLine.backgroundColor = [UIColor darkGrayColor];
        [_footerView addSubview:seperationLine];
        [seperationLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.height.mas_equalTo(0.5);
        }];
        [_footerView addSubview:self.mailDetailWebView];
        [self.mailDetailWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(1);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.bottom.mas_equalTo(0);
        }];
    }
    return _footerView;
}

- (UIView *)subjectView{
    if (!_subjectView) {
        _subjectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.font = kFont_20;
        titleLabel.text = self.mailModel.subject;
        titleLabel.numberOfLines = 0;
        [_subjectView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.bottom.mas_equalTo(0);
        }];
    }
    return _subjectView;
}

@end
