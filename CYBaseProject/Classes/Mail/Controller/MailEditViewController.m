//
//  MailEditViewController.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/11.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailEditViewController.h"
#import "MailAddressCell.h"
#import "MailAddAddrTextParser.h"
#import "MailTopicCell.h"
#import "MailAttachmentCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "JSImagePickerViewController.h"
#import <Masonry.h>
#import "CYMailUtil.h"
#import "CYMailModelManager.h"
#import "CYMailSessionManager.h"
#import "CYTempAttachment.h"

#define kKeyPath @"contentOffset"

@interface MailEditViewController ()<JSImagePickerViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextView *editTextView;
@property (nonatomic, strong) MailAddressCell *toAddrCell;
@property (nonatomic, strong) MailAddressCell *ccAddrCell;
@property (nonatomic, strong) MailAddressCell *bccAddrCell;
@property (nonatomic, strong) MailTopicCell *subjectCell;
@property (nonatomic,strong) NSMutableArray *attachments;
@property (nonatomic, strong, readonly) CYMailSession *session;

@end

static NSString * const demoCellReuseIdentifier = @"MailEditViewController";

@implementation MailEditViewController

+ (instancetype)controllerWithAccount:(CYMailAccount *)account editType:(CYMailEditType)editType originMail:(CYMail *)originMail {
    MailEditViewController *ctrl = [[MailEditViewController alloc]initWithAccount:account editType:editType originMail:originMail];
    return ctrl;
}

- (instancetype)initWithAccount:(CYMailAccount *)account editType:(CYMailEditType)editType originMail:(CYMail *)originMail {
    self = [super init];
    if (self) {
        _account = account;
        _editType = editType;
        _originMail = originMail;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubviews];
}

#pragma mark - InitSubview
- (void)configureSubviews{
    
    //header view
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(64);
    }];
    
    switch (self.editType) {
        case CYMailEditTypeNew:{
            break;
        }
        case CYMailEditTypeReply:{
            //title
            self.subjectCell.content = [NSString stringWithFormat:@"%@:%@",MsgReply,self.originMail.subject];
            //To
            self.toAddrCell.content = self.originMail.fromAddress;
            //Cc
            self.ccAddrCell.content = self.originMail.cc;
            //content
            self.editTextView.attributedText = [CYMailUtil generateReplyContent:self.originMail];
            break;
        }
        case CYMailEditTypeForward:
        case CYMailEditTypeSimpleForward:{
            //title
            self.subjectCell.content = [NSString stringWithFormat:@"%@:%@",MsgForward,self.originMail.subject];
            //content
            self.editTextView.attributedText = [CYMailUtil generateReplyContent:self.originMail];
        }
        default:
            break;
    }
    
    //tableview
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
}

#pragma mark - DelegateMethod
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0?4:self.attachments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id cell;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell = self.toAddrCell;
                    break;
                case 1:
                    cell = self.ccAddrCell;
                    break;
                case 2:
                    cell = self.bccAddrCell;
                    break;
                default:
                    cell = self.subjectCell;
                    break;
            }
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:demoCellReuseIdentifier forIndexPath:indexPath];
            ((MailAttachmentCell *)cell).attachment = self.attachments[indexPath.row];

            break;
            
        default:
            break;
    }
    
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return self.editTextView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 80;
    }else{
        CGFloat height = [tableView fd_heightForCellWithIdentifier:demoCellReuseIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
            ((MailAttachmentCell *)cell).attachment = self.attachments[indexPath.row];
        }];
        return height>44?height:44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section==0?0.0001:500.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0?0.0001:0.1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section== 1){
        return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1){
        return UITableViewCellEditingStyleDelete;
    }else{
        return UITableViewCellEditingStyleNone;
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1){
    
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:MsgDelete  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){

            [self.attachments removeObjectAtIndex:indexPath.row];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        return @[deleteAction];
    }else{
        return nil;
    }
}

#pragma mark -JSImageDelegate
- (void)imagePicker:(JSImagePickerViewController *)imagePicker didSelectImage:(UIImage *)image andALAssetRepresentation:(id)ALAssetRepresentation{
    
    NSString *fileName = @"";
    if ([ALAssetRepresentation isKindOfClass:[ALAssetRepresentation class]]) {
        fileName = [ALAssetRepresentation filename];
    }
    NSData *fileData = UIImagePNGRepresentation(image);
    
    CYTempAttachment *attachment = [CYTempAttachment attachmentModelWithFileName:fileName fileData:fileData];
    
    [self.attachments addObject:attachment];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - NetworkMethod
-(void)sendMail{
    
    NSString *toAddr = [self.toAddrCell.content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *ccAddr = [self.ccAddrCell.content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *bccAddr = [self.bccAddrCell.content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *subject = self.subjectCell.content;
    
    NSMutableArray *toArrs =[NSMutableArray arrayWithArray:[toAddr componentsSeparatedByString:@","]] ;
    NSMutableArray *ccArrs =[NSMutableArray arrayWithArray:[ccAddr componentsSeparatedByString:@","]];
    NSMutableArray *bccArrs = [NSMutableArray arrayWithArray:[bccAddr componentsSeparatedByString:@","]];
    [toArrs enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSString isBlankString:obj]) {
            [toArrs removeObject:obj];
        }
    }];
    [ccArrs enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSString isBlankString:obj]) {
            [ccArrs removeObject:obj];
        }
    }];
    [bccArrs enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSString isBlankString:obj]) {
            [bccArrs removeObject:obj];
        }
    }];
    
    CYMail *orginMail = nil;
    if (self.editType == CYMailEditTypeForward) {
        orginMail = self.originMail;
    }
    
    [self showHudWithMsg:MsgSending];
    __weak typeof(self) weakSelf = self;
    [self.session sendMailWithSubject:subject content:self.editTextView.text toArray:toArrs ccArray:ccArrs bccArray:bccArrs attachmentArray:self.attachments originMail:orginMail success:^{
        [weakSelf hideHuds];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        [weakSelf hideHuds];
        [weakSelf showToast:[NSString stringWithFormat:@"%@",error.userInfo[NSLocalizedDescriptionKey]]];
    } progress:^(NSInteger current, NSInteger maximum) {
        [weakSelf hideMsgHud];
        [weakSelf showProgressHudWithMsg:MsgSending precentage:current*1.0/maximum];
    }];

}
#pragma mark - Event Response
- (void)clickAttachmentButton{
    JSImagePickerViewController *imagePicker = [[JSImagePickerViewController alloc] init];
    imagePicker.delegate = self;
    [imagePicker showImagePickerInController:self animated:YES];

}

- (void)clickCancelButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickSendButton{
    [self.view endEditing:YES];
    if([NSString isBlankString:self.toAddrCell.content] ){
        [self showToast:@"请您选择收件人!"];
        return;
    }
    if( [NSString isBlankString:self.subjectCell.content]){
        [self showToast:@"请填写邮件主题!"];
        return;
    }
    
    [self sendMail];
}

#pragma mark -Getters and Setters
- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc]init];
        _headerView.backgroundColor = UICOLOR(@"#F5F5F5");
        
        UIButton *cancelButton = [[UIButton alloc]init];
        [cancelButton setTitle:MsgCancel forState:UIControlStateNormal];
        [cancelButton setTitleColor:UICOLOR(@"#2D4664") forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelButton addTarget:self action:@selector(clickCancelButton) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView.mas_top).offset(20);
            make.left.mas_equalTo(15);
            make.width.mas_equalTo(50);
            make.bottom.equalTo(_headerView.mas_bottom);
        }];
        
        UIButton *sendButton = [[UIButton alloc]init];
        [sendButton setTitle:MsgSend forState:UIControlStateNormal];
        [sendButton setTitleColor:UICOLOR(@"#2D4664") forState:UIControlStateNormal];
        sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [sendButton addTarget:self action:@selector(clickSendButton) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:sendButton];
        [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView.mas_top).offset(20);
            make.right.mas_equalTo(-15);
            make.width.mas_equalTo(50);
            make.bottom.equalTo(_headerView.mas_bottom);
        }];
    }
    return _headerView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.estimatedRowHeight = 44;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        
        [_tableView registerNib:[UINib nibWithNibName:@"MailAttachmentCell" bundle:nil] forCellReuseIdentifier:demoCellReuseIdentifier];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.allowsSelection = NO;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UITextView *)editTextView{
    if (!_editTextView) {
        _editTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 500)];
        _editTextView.font = [UIFont systemFontOfSize:15];
    }
    return _editTextView;
}

- (NSMutableArray *)attachments{
    if(!_attachments){
        _attachments  = [NSMutableArray array];
    }
    return _attachments;
}

- (MailAddressCell *)toAddrCell{
    if (!_toAddrCell) {
        _toAddrCell = [[MailAddressCell alloc]init];
        _toAddrCell.title = MsgTo;
    }
    return _toAddrCell;
}

- (MailAddressCell *)ccAddrCell{
    if (!_ccAddrCell) {
        _ccAddrCell = [[MailAddressCell alloc]init];
        _ccAddrCell.title = MsgCc;
    }
    return _ccAddrCell;
}

- (MailAddressCell *)bccAddrCell{
    if (!_bccAddrCell) {
        _bccAddrCell= [[MailAddressCell alloc]init];
        _bccAddrCell.title = MsgBcc;
    }
    return _bccAddrCell;
}

- (MailTopicCell *)subjectCell{
    if (!_subjectCell) {
        _subjectCell = (MailTopicCell*) ([[NSBundle mainBundle]loadNibNamed:@"MailTopicCell" owner:nil options:nil].lastObject);
        __weak typeof(self) weakSelf = self;
        _subjectCell.attachBlock = ^(){
            [weakSelf clickAttachmentButton];
        };
    }
    return _subjectCell;
}

- (CYMailSession *)session{
    return [[CYMailSessionManager sharedCYMailSessionManager]getSessionWithUsername:self.account.username];
}

@end
