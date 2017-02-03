//
//  AttachmentViewController.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/28.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailAttachmentViewController.h"
#import "YYSandBoxUtil.h"
#import "MailAttachmentTableViewCell.h"
#import "DocPreviewUtil.h"
#import "CYMailModelManager.h"
#import "CYMailSessionManager.h"
#import <Masonry.h>
#import "CYMailUtil.h"

@interface MailAttachmentViewController ()<UITableViewDelegate,UITableViewDataSource,CAAnimationDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *coverButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<CYAttachment *> *attachments;
@property (nonatomic, strong, readonly) CYMailSession *session;
@property (nonatomic, assign, getter=isAnimating) BOOL animating;

@end

@implementation MailAttachmentViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubviews];
}

- (void)viewWillAppear:(BOOL)animated{
    [self fadeInAnimate];
}

- (void)configureSubviews{
    self.view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [self.view addSubview:self.coverButton];
    [self.coverButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.view addSubview:self.backgroundView];
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.8);
    }];
}

#pragma mark - Animate method
- (void)fadeInAnimate{
    CABasicAnimation *animation = [CABasicAnimation animation];
    [animation setDuration:0.25];
    animation.keyPath = @"position.x";
    animation.fromValue = @(ScreenWidth*1.4);
    animation.toValue = @(ScreenWidth*0.6);
    [self.backgroundView.layer addAnimation:animation forKey:nil];
}

- (void)fadeOutAnimate{
    if (self.isAnimating) {
        return;
    }
    self.animating = YES;
    CABasicAnimation *animation = [CABasicAnimation animation];
    [animation setDuration:0.25];
    animation.delegate = self;
    animation.keyPath = @"position.x";
    animation.fromValue = @(ScreenWidth*0.6);
    animation.toValue = @(ScreenWidth*1.4);
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [self.backgroundView.layer addAnimation:animation forKey:nil];
}

#pragma mark - Delegate Methods
#pragma mark Animate Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.attachments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MailAttachmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MailAttachmentTableViewCell reuseIdentifier]];
    
    CYAttachment *attachment = self.attachments[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    if (!cell) {
        cell = [[MailAttachmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MailAttachmentTableViewCell reuseIdentifier]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.openBlock = ^(){
            [weakSelf openAttachment:attachment];
        };
        cell.downloadBlock = ^(){
            [weakSelf downlLoadAttachment:attachment];
        };
    }
    cell.attachment = attachment;
    
    return cell;
}

#pragma mark - Network Methods
- (void)downlLoadAttachment:(CYAttachment *)attachment{
    
    NSString *filePath = [[CYMailUtil attachmentFolderOfMail:attachment.ownerMail] stringByAppendingPathComponent:attachment.filename];
    [self showHudWithMsg:[NSString stringWithFormat:@"%@",MsgLoading]];
    [self.session downloadAttachment:attachment downloadPath:filePath success:^{
        [self hideHuds];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self hideHuds];
        [self.tableView reloadData];
    } progress:^(NSInteger current, NSInteger maximum) {
        [self hideMsgHud];
        [self showProgressHudWithMsg:MsgDownloading precentage:current*1.0/maximum];
    }];
    
}

#pragma mark - Event Response
- (void)openAttachment:(CYAttachment *)attachment{

    NSString *filePath = [[CYMailUtil attachmentFolderOfMail:attachment.ownerMail] stringByAppendingPathComponent:attachment.filename];
    
    BOOL result = [[DocPreviewUtil shareUtil] previewDocOfPath:filePath controller:self completion:^{
    }];
    
    if (result) return;
    
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:nil message:MsgPreviewInOtherApp preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:MsgYes style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[DocPreviewUtil shareUtil] previewInOtherAppOfPath:filePath controller:self completion:^{
        }];
        
    }];
    [alerController addAction:confirmAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:MsgCancel style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alerController addAction:cancelAction];
    
    [self presentViewController:alerController animated:YES completion:nil];
}

#pragma mark -Getters and Setters
- (UITableView *)tableView{
    if(!_tableView){
        _tableView  =({
            UITableView *var =[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
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
    return _tableView;
}

- (UIButton *)coverButton{
    if (!_coverButton) {
        _coverButton = [[UIButton alloc]init];
        [_coverButton addTarget:self action:@selector(fadeOutAnimate) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coverButton;
}

- (UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc]init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        
        UIView *headerView = [[UIView alloc]init];
        headerView.backgroundColor = UICOLOR(@"#F5F5F5");
        [_backgroundView addSubview:headerView];
        [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_backgroundView.mas_top);
            make.left.equalTo(_backgroundView.mas_left);
            make.right.equalTo(_backgroundView.mas_right);
            make.height.mas_equalTo(64);
        }];
        
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.text = MsgAttachment;
        titleLabel.textColor = UICOLOR(@"#2D4664");
        [headerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView.mas_top).offset(20);
            make.left.equalTo(headerView.mas_left);
            make.right.equalTo(headerView.mas_right);
            make.bottom.equalTo(headerView.mas_bottom);
        }];
        
        [_backgroundView addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView.mas_bottom);
            make.right.equalTo(_backgroundView.mas_right);
            make.left.equalTo(_backgroundView.mas_left);
            make.bottom.equalTo(_backgroundView.mas_bottom);
        }];
    }
    return _backgroundView;
}

- (NSArray *)attachments{
    if (!_attachments) {
        _attachments = [self.mail.attachments allObjects];
        if (!_attachments) {
            _attachments = @[];
        }
    }
    return _attachments;
}

- (CYMailSession *)session{
    return [[CYMailSessionManager sharedCYMailSessionManager]getSessionWithUsername:self.mail.account];
}

@end
