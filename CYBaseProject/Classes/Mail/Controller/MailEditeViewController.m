//
//  MailEditeViewController.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/11.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailEditeViewController.h"
#import "MailAddAddrCell.h"
#import "YYText.h"
#import "MailAddAddrTextParser.h"
#import "MailTopicCell.h"
#import "MailAttachmentCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MailAttachmentHeader.h"
#import "JSImagePickerViewController.h"
#import "ZTEMailModel.h"
#import "ZTEMailSessionUtil.h"

#define kKeyPath @"contentOffset"

@interface MailEditeViewController ()<YYTextViewDelegate,UITextViewDelegate,JSImagePickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextView *editTextView;

//用于保存输入内容
@property (nonatomic,strong) NSMutableAttributedString *toAddr;//收件人
@property (nonatomic,strong) NSMutableAttributedString *ccAddr;//抄送
@property (nonatomic,strong) NSMutableAttributedString *bccAddr;//密送
@property (nonatomic,strong) NSString *topicStr;//主题

@property (nonatomic,strong) NSMutableArray *attachments;

@end

static NSString * const demoCellReuseIdentifier = @"MailEditeViewController";

@implementation MailEditeViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubview];
}

#pragma mark - InitSubview
- (void)configureSubview{
    
    self.title = @"写邮件";
    self.myTableView.estimatedRowHeight =  44;
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
    
    //初始化邮件内容
    self.topicStr = self.subject;
    self.toAddr = [self generateAddrWithAddrStr:self.to];
    if (![NSString isBlankString:self.cc]) {
        self.ccAddr = [self generateAddrWithAddrStr:self.cc];
    }
    
    if (self.mailModel) {
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[[self generateForwardContent] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        self.editTextView.attributedText = attributedString;
    }
    
    //只有附件部分的 cell 重用
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailAttachmentCell" bundle:nil] forCellReuseIdentifier:demoCellReuseIdentifier];
    
    UIBarButtonItem *sendMailItem = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnClicked:)];
    sendMailItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = sendMailItem;
    
}

#pragma mark - DelegateMethod
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0?4:self.attachments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id cell ;
    switch (indexPath.section) {
        case 0:
            if (indexPath.row<3) {
                cell = (MailAddAddrCell*)([[NSBundle mainBundle]loadNibNamed:@"MailAddAddrCell" owner:nil options:nil].lastObject);
                [self configureEditCellWithCell:cell andIndexPath:indexPath];
                
            }else{
                cell = (MailTopicCell*) ([[NSBundle mainBundle]loadNibNamed:@"MailTopicCell" owner:nil options:nil].lastObject);
                ((MailTopicCell *)cell).topicTextView.delegate =self;
                ((MailTopicCell *)cell).topicTextView.text = self.topicStr;
            }

            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:demoCellReuseIdentifier forIndexPath:indexPath];
            [self configureAttachmentCell:cell andIndexPath:indexPath];

            break;
            
        default:
            break;
    }
    
    return cell;
    
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1){
      MailAttachmentHeader *header =  (MailAttachmentHeader *)([[NSBundle mainBundle]loadNibNamed:@"MailAttachmentHeader" owner:nil options:nil].lastObject);
        [header.addAttachmentBtn addTarget:self action:@selector(addAttachmentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        return header;
    }else{
         return [[UIView alloc]initWithFrame:CGRectZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 80;
    }
    else{
        return [tableView fd_heightForCellWithIdentifier:demoCellReuseIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
            [self configureAttachmentCell:cell andIndexPath:indexPath];
        }];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0?0.0001:44;
}

//设置允许编辑的 cell
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section== 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

//编辑类型
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1)
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

// 自定义编辑事件
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1) {
    
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){

            [self.attachments removeObjectAtIndex:indexPath.row];
            [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        return @[deleteAction];
    }
    else
    {
        return nil;
    }
}

#pragma mark - Delegate Method
#pragma mark - YYDelegte
- (void)textViewDidChange:(YYTextView *)textView {
    if (textView.text.length == 0) {
        textView.textColor = [UIColor blackColor];
    }
    if([textView isKindOfClass:[UITextView class]] && textView.tag != 8){
        if(self.subject){
            self.topicStr =[NSString stringWithFormat:@"%@ %@",self.subject,textView.text];
        }else{
            self.topicStr = textView.text;
        }
    }
    
}

- (void)textViewDidBeginEditing:(YYTextView *)textView {

}

- (void)textViewDidEndEditing:(YYTextView *)textView {
    [self.view endEditing:YES];
    
    NSString *muStr;
    if([textView isKindOfClass:[YYTextView class]] && ![muStr isEqualToString:textView.attributedText.string])
    {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:textView.tag inSection:0];
        if(idx.row == 0 )
        {
            [self.toAddr appendAttributedString:textView.attributedText];
        }
        else if (idx.row ==1)
        {
             [self.ccAddr appendAttributedString:textView.attributedText];
        }
        else
        {
            [self.bccAddr appendAttributedString:textView.attributedText];

        }
        muStr = textView.attributedText.string;
    }
}

#pragma mark -JSImageDelegate
- (void)imagePicker:(JSImagePickerViewController *)imagePicker didSelectImage:(UIImage *)image andALAssetRepresentation:(id)ALAssetRepresentation{
    
    NSString *fileName = @"";
    if ([ALAssetRepresentation isKindOfClass:[ALAssetRepresentation class]]) {
        fileName = [ALAssetRepresentation filename];
    }
    NSData *fileData = UIImagePNGRepresentation(image);
    
    ZTEAttachmentModel *attachment = [ZTEAttachmentModel attachmentModelWithFileName:fileName fileData:fileData];
    
    [self.attachments addObject:attachment];
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Private Methods
//收件人.抄送.密送 cell
-(void)configureEditCellWithCell:(MailAddAddrCell *)cell andIndexPath:(NSIndexPath *)indexPath{
    NSArray *arr = @[@"收件人:",@"抄    送:",@"密    送:"];
    cell.titleLabel.text =  arr[indexPath.row];
    cell.inputView.delegate = self;
    cell.inputView.textParser = [MailAddAddrTextParser new];
    cell.inputView.tag = indexPath.row;
    cell.inputView.placeholderText =  @"邮件地址请用逗号隔开!";
    switch (indexPath.row) {
        case 0:
            cell.inputView.attributedText = self.toAddr;
            break;
        case 1:
            cell.inputView.attributedText = self.ccAddr;
            break;
        case 2:
            cell.inputView.attributedText = self.bccAddr;
            break;
        default:
            break;
    }
    
    //选择联系人按钮（隐藏）
    [cell.addAddrBtn addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.addAddrBtn.tag = indexPath.row;
    cell.addAddrBtn.hidden = YES;
    cell.addAddrBtn.enabled = NO;

}

//附件 cell
-(void)configureAttachmentCell:(MailAttachmentCell*)cell andIndexPath:(NSIndexPath *)indexPath
{
    ((MailAttachmentCell *)cell).attchmentTitle.text = [NSString stringWithFormat:@"附件%ld:",indexPath.row+1];
    ZTEAttachmentModel *attachment = self.attachments[indexPath.row];
    ((MailAttachmentCell *)cell).attchmentLabel.text = attachment.fileName;
}


- (NSMutableAttributedString *)generateAddrWithAddrStr:(NSString *)addrStr{
    if([NSString isBlankString:addrStr]){
        return [NSMutableAttributedString new];
    }
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:addrStr];
    text.yy_font = [UIFont systemFontOfSize:15];
    text.yy_lineSpacing = 3;
    text.yy_color = [UIColor blackColor];
    return text;
}

/**
 *  tableview 移动至顶部
 */
- (void)scrollToTop
{
    [UIView animateWithDuration:1.0f delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:25.0f options:UIViewAnimationOptionShowHideTransitionViews animations:^{
        [self.myTableView setContentOffset: CGPointZero];
    } completion:^(BOOL finished) {
    }];
}

- (NSString *)generateForwardContent{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    
    NSMutableString *forwardContent = [NSMutableString stringWithString:@"<br/><br/><br/><br/><br/>"];
    [forwardContent appendString:@"------------转发的邮件------------<br/>"];
    [forwardContent appendString:[NSString stringWithFormat:@"发件人:%@<br/>",self.mailModel.fromAddress]];
    [forwardContent appendString:[NSString stringWithFormat:@"发送日期:%@<br/>",[formatter stringFromDate:self.mailModel.sendDate]]];
    [forwardContent appendString:[NSString stringWithFormat:@"收件人:%@<br/>",self.mailModel.to]];
    [forwardContent appendString:[NSString stringWithFormat:@"主题:%@<br/>",self.mailModel.subject]];
    [forwardContent appendString:@"*********************************<br/>"];
    [forwardContent appendString:self.mailModel.content];
    return [forwardContent copy];
}

#pragma mark - NetworkMethod
-(void)sendMail{
    
    NSMutableArray *toArrs =(NSMutableArray *) [self.toAddr.string componentsSeparatedByString:@","] ;
    NSMutableArray *ccArrs =(NSMutableArray *) [self.ccAddr.string componentsSeparatedByString:@","];
    NSMutableArray *bccArrs = (NSMutableArray *) [self.bccAddr.string componentsSeparatedByString:@","];
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
    
    NSString *folder;
    NSInteger uid;
    if (self.mailModel) {
        folder = self.mailModel.folderPath;
        uid = [self.mailModel.uid integerValue];
    }
    
    [self showHudWithMsg:@"正在发送..."];
    __weak typeof(self) weakSelf = self;
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    [util sendMailWithSubject:self.topicStr content:self.editTextView.text toArray:toArrs ccArray:ccArrs bccArray:bccArrs imageAttachmentArray:self.attachments uid:uid folder:folder success:^{
        
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
#pragma mark - Event Response
- (void)addAttachmentBtnClicked:(UIButton *)sender{
    JSImagePickerViewController *imagePicker = [[JSImagePickerViewController alloc] init];
    imagePicker.delegate = self;
    [imagePicker showImagePickerInController:self animated:YES];

}

- (void)addBtnClicked:(UIButton *)sender{
    
}

-(void)rightBtnClicked:(UIButton *)sender
{
    if([NSString isBlankString: self.toAddr.string] ){
        [self.view makeToast:@"请您选择收件人!"];
        return;
    }
    if( [NSString isBlankString:self.topicStr]){
        [self.view makeToast:@"请填写邮件主题!"];
        return;
    }
    
    [self sendMail];
}


#pragma mark -Getters and Setters
-(NSMutableArray *)attachments{
    if(!_attachments){
        _attachments  = [NSMutableArray array];
    }
    return _attachments;
}

@end
