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

static CGFloat ImageViewWidth = 20.f;

@implementation MailBottomButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *btnColor = UICOLOR(@"#555555");
        [self setTitleColor:btnColor forState:UIControlStateNormal];
        self.titleLabel.font = kFont_12;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imageW = ImageViewWidth;
    CGFloat imageH = ImageViewWidth;
    CGFloat imageX = (contentRect.size.width - imageW)/2 ;
    CGFloat imageY = 5;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, contentRect.size.height - 12 -5, contentRect.size.width, 12);
}

@end

static NSString *kMailDetailCellId = @"MailContactCell";

@interface MailDetailViewController ()<SideSlipViewDelegate,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *infosArray;
@property (nonatomic, strong) NSArray *modifyIndexPaths;
@property (nonatomic, strong) NSArray *ccArray;
@property (nonatomic, strong) NSArray *toArray;
@property (nonatomic, strong) NSArray<ZTEMailAttachment *> *attachments;
@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, assign) CGFloat subjectHeight;
@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) SideSlipView *sideSlipView;
@property (nonatomic, strong) MailAttachmentViewController *attachmentVC;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIWebView *mailDetailWebView;
@property (nonatomic, strong) UIView *subjectView;
@property (nonatomic, assign) BOOL isUnfold;
@property (nonatomic, assign) BOOL isLoadingFinished;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation MailDetailViewController

#pragma mark - Life Cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    [self configureSubview];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.sideSlipView hide];
}

#pragma mark - init Views
- (void)configureSubview{
    
    self.title = @"邮件详情";
    
    self.subjectHeight = [self.mailModel.subject boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-32, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kFont_20} context:nil].size.height+15;
    
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
    self.myTableView.estimatedRowHeight = 25;
    [self.myTableView registerNib:[UINib nibWithNibName:kMailDetailCellId bundle:nil] forCellReuseIdentifier:kMailDetailCellId];
    self.myTableView.backgroundColor = [UIColor whiteColor];
    
    [self configureBottomButton];
}

- (void)configureBottomButton{
    
    CGFloat btnWidth = [UIScreen mainScreen].bounds.size.width/4;
    CGFloat btnHeight = self.bottomView.frame.size.height;
    
    MailBottomButton *replyButton = [self generateBottomButtonWithTitle:@"回复/转发" imageName:@"tab_reply" frame:CGRectMake(0,0,btnWidth,btnHeight)];
    [replyButton addTarget:self action:@selector(clickReplyButton) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:replyButton];
    
    MailBottomButton *deleteButton = [self generateBottomButtonWithTitle:@"删除" imageName:@"tab_delete" frame:CGRectMake(btnWidth,0,btnWidth,btnHeight)];
    [deleteButton addTarget:self action:@selector(deleteMail) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:deleteButton];
    
    MailBottomButton *moveButton = [self generateBottomButtonWithTitle:@"移动" imageName:@"tab_move" frame:CGRectMake(btnWidth*2,0,btnWidth,btnHeight)];
    [moveButton addTarget:self action:@selector(pushFolderChoice) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:moveButton];
    
    //附件
    if(self.attachments.count>0){
        MailBottomButton *replyButton = [self generateBottomButtonWithTitle:@"附件" imageName:@"attachment" frame:CGRectMake(btnWidth*3,0,btnWidth,btnHeight)];
        [replyButton addTarget:self action:@selector(clickAttachmentButton) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:replyButton];
    }
    
}

- (MailBottomButton *)generateBottomButtonWithTitle:(NSString *)title imageName:(NSString *)imageName frame:(CGRect)frame{
    MailBottomButton *btn = [[MailBottomButton alloc]initWithFrame:frame];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
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
    
    [self.myTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark webView
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self hideHud];
    
    if(self.isLoadingFinished){
        
        //获取缩放后高度
        CGFloat webViewHeight =[[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth"]floatValue]+30;
        CGRect newFrame = webView.frame;
        newFrame.size.height= webViewHeight;
        newFrame.size.width = [UIScreen mainScreen].bounds.size.width;
        self.webViewHeight = webViewHeight;
        self.footerView.frame= newFrame;
        
        [self.myTableView reloadData];
        
        return;
    }
    
    //js获取body宽度
    NSString *bodyWidth= [webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollWidth"];
    
    int widthOfBody = [bodyWidth intValue];
    
    //获取实际要显示的html，调整缩放大小
    NSString *html = [self htmlAdjustWithPageWidth:widthOfBody
                                              html:self.mailModel.content
                                           webView:webView];
    
    self.isLoadingFinished = YES;
    //加载实际要现实的html
    [webView loadHTMLString:html baseURL:nil];
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

- (NSString *)htmlAdjustWithPageWidth:(CGFloat )pageWidth
                                 html:(NSString *)html
                              webView:(UIWebView *)webView {
    NSMutableString *str = [NSMutableString stringWithString:html];
    //计算要缩放的比例
    CGFloat initialScale = webView.frame.size.width/pageWidth;
    //将</head>替换为meta+head
    NSString *stringForReplace = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\" initial-scale=%f, minimum-scale=0.1, maximum-scale=2.0, user-scalable=yes\"></head>",initialScale];
    
    NSRange range =  NSMakeRange(0, str.length);
    //替换
    [str replaceOccurrencesOfString:@"</head>" withString:stringForReplace options:NSLiteralSearch range:range];
    return str;
}

#pragma mark - Mail method
- (void)pushFolderChoice{
    MailFolderViewController *folder = [[MailFolderViewController alloc]init];
    folder.mailModel = self.mailModel;
    [self.navigationController pushViewController:folder animated:YES];
}

- (void)pushReplyAll{
    MailEditeViewController *edite = [[MailEditeViewController  alloc]init];
    edite.subject = [NSString stringWithFormat:@"回复 : %@",self.mailModel.subject];
    edite.to = [NSString stringWithFormat:@"%@,", self.mailModel.fromAddress];
    if (![NSString isBlankString:self.mailModel.cc]) {
        edite.cc = [NSString stringWithFormat:@"%@,", self.mailModel.cc];
    }
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

#pragma mark - Network method
- (void)deleteMailWithFolder:(NSString *)folder uid:(NSInteger)uid{
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    if ([util isTrashFolder:self.folderModel]) {//已在垃圾箱
        [util deleteMailWithFolder:folder uid:uid success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }else{//未在垃圾箱
        ZTEFolderModel *folderModel = [util loadTrashFolder];
        if (folderModel) {
            [util moveMessagesWithFolder:folder uid:uid destFolder:folderModel.path success:^{
                
            } failure:^(NSError *error) {
                
            }];
        }
    }
}

#pragma mark - Event Response
//弹出附件
- (void)clickAttachmentButton {
    
    [self.sideSlipView removeFromSuperview];
    [self.sideSlipView.hideSideSlipBtn removeFromSuperview];
    
    [self.view addSubview:self.sideSlipView];
    [self.view addSubview:self.sideSlipView.hideSideSlipBtn];
    [self.sideSlipView show];
}

- (void)clickReplyButton{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"回复" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pushReplyAll];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"转发" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pushForward];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
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

- (MailAttachmentViewController *)attachmentVC{
    if (!_attachmentVC) {
        _attachmentVC = [[MailAttachmentViewController alloc] initWithOwnerAddress:[ZTEMailSessionUtil shareUtil].username folderPath:self.mailModel.folderPath uid:[self.mailModel.uid integerValue] attachments:self.attachments parentController:self];
    }
    return _attachmentVC;
}

- (NSArray *)attachments{
    
    if (!_attachments) {
        _attachments = [self.mailModel.attachments allObjects];
    }
    return _attachments;
    
}

- (UIWebView *)mailDetailWebView{
    if (!_mailDetailWebView) {
        _mailDetailWebView = [[UIWebView alloc]init];
        _mailDetailWebView.delegate = self;
        _mailDetailWebView.scrollView.bounces = NO;
        _mailDetailWebView.scalesPageToFit = NO;
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
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.bottom.mas_equalTo(0);
        }];
    }
    return _subjectView;
}

@end
