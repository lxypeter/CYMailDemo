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
#import "ZTEFolderModel.h"

#define kKeyPath @"contentOffset"

@interface MailEditeViewController ()<JSImagePickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextView *editTextView;

@property (nonatomic, strong) MailAddAddrCell *toAddrCell;
@property (nonatomic, strong) MailAddAddrCell *ccAddrCell;
@property (nonatomic, strong) MailAddAddrCell *bccAddrCell;
@property (nonatomic, strong) MailTopicCell *subjectCell;

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
    
    if (self.mailModel) {
        self.editTextView.attributedText = [self generateForwardContent];
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
    if(indexPath.section== 1){
        return YES;
    }
    return NO;
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
- (MailAddAddrCell *)generateEditCellWithTitle:(NSString *)title{
    MailAddAddrCell *cell = (MailAddAddrCell*)([[NSBundle mainBundle]loadNibNamed:@"MailAddAddrCell" owner:nil options:nil].lastObject);
    cell.titleLabel.text = title;
    cell.inputView.textParser = [MailAddAddrTextParser new];
    cell.inputView.placeholderText =  @"邮件地址请用逗号隔开!";
    return cell;
}

//附件 cell
- (void)configureAttachmentCell:(MailAttachmentCell*)cell andIndexPath:(NSIndexPath *)indexPath{
    ((MailAttachmentCell *)cell).attchmentTitle.text = [NSString stringWithFormat:@"附件%ld:",indexPath.row+1];
    ZTEAttachmentModel *attachment = self.attachments[indexPath.row];
    ((MailAttachmentCell *)cell).attchmentLabel.text = attachment.fileName;
}

- (NSMutableAttributedString *)generateForwardContent{
    
    NSMutableAttributedString *forwardContent = [[NSMutableAttributedString alloc]init];
    
    //头部
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSMutableString *forwardHeader = [NSMutableString stringWithString:@"\n\n\n\n\n"];
    [forwardHeader appendString:@"------------原邮件------------\n"];
    [forwardHeader appendString:[NSString stringWithFormat:@"发件人:%@\n",self.mailModel.fromAddress]];
    [forwardHeader appendString:[NSString stringWithFormat:@"发送日期:%@\n",[formatter stringFromDate:self.mailModel.sendDate]]];
    [forwardHeader appendString:[NSString stringWithFormat:@"收件人:%@\n",self.mailModel.to]];
    [forwardHeader appendString:[NSString stringWithFormat:@"主题:%@\n",self.mailModel.subject]];
    [forwardHeader appendString:@"*********************************\n"];
    
    [forwardContent appendAttributedString:[[NSAttributedString alloc]initWithString:forwardHeader attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}]];
    
    NSAttributedString *forwardBody = [[NSAttributedString alloc] initWithData:[self.mailModel.content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [forwardContent appendAttributedString:forwardBody];
    
    return forwardContent;
}

#pragma mark - NetworkMethod
-(void)sendMail{
    
    NSString *toAddr = [self.toAddrCell.inputView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *ccAddr = [self.ccAddrCell.inputView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *bccAddr = [self.bccAddrCell.inputView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *subject = self.subjectCell.topicTextView.text;
    
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
    
    NSString *folder;
    NSInteger uid;
    if (self.mailModel) {
        folder = self.mailModel.folderPath;
        uid = [self.mailModel.uid integerValue];
    }
    
    [self showHudWithMsg:@"正在发送..."];
    __weak typeof(self) weakSelf = self;
    ZTEMailSessionUtil *util = [ZTEMailSessionUtil shareUtil];
    [util sendMailWithSubject:subject content:self.editTextView.text toArray:toArrs ccArray:ccArrs bccArray:bccArrs imageAttachmentArray:self.attachments uid:uid folder:folder sentFolder:[util loadSentFolder].path success:^{
        
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

- (void)rightBtnClicked:(UIButton *)sender{
    [self.view endEditing:YES];
    if([NSString isBlankString: self.toAddrCell.inputView.text] ){
        [self.view makeToast:@"请您选择收件人!"];
        return;
    }
    if( [NSString isBlankString:self.subjectCell.topicTextView.text]){
        [self.view makeToast:@"请填写邮件主题!"];
        return;
    }
    
    [self sendMail];
}


#pragma mark -Getters and Setters
- (NSMutableArray *)attachments{
    if(!_attachments){
        _attachments  = [NSMutableArray array];
    }
    return _attachments;
}

- (MailAddAddrCell *)toAddrCell{
    if (!_toAddrCell) {
        _toAddrCell = [self generateEditCellWithTitle:@"收件人:"];
        _toAddrCell.inputView.text = self.to;
    }
    return _toAddrCell;
}

- (MailAddAddrCell *)ccAddrCell{
    if (!_ccAddrCell) {
        _ccAddrCell = [self generateEditCellWithTitle:@"抄    送:"];
        _ccAddrCell.inputView.text = self.cc;
    }
    return _ccAddrCell;
}

- (MailAddAddrCell *)bccAddrCell{
    if (!_bccAddrCell) {
        _bccAddrCell = [self generateEditCellWithTitle:@"密    送:"];
    }
    return _bccAddrCell;
}

- (MailTopicCell *)subjectCell{
    
    if (!_subjectCell) {
        _subjectCell = (MailTopicCell*) ([[NSBundle mainBundle]loadNibNamed:@"MailTopicCell" owner:nil options:nil].lastObject);
        _subjectCell.topicTextView.text = self.subject;
    }
    return _subjectCell;
    
}
@end
