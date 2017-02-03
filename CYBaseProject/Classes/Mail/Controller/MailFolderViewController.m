//
//  MailFolderViewController.m
//  GXMoblieOA
//
//  Created by YYang on 16/5/4.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailFolderViewController.h"
#import <Masonry.h>
#import "CYMailSessionManager.h"
#import "CYMailModelManager.h"
#import "CYMailUtil.h"

static NSString *const reuseableID = @"MailFolderCell";

@interface MailFolderViewController ()<UITableViewDelegate,UITableViewDataSource,CAAnimationDelegate>
@property (nonatomic, strong, readonly) CYMailSession *session;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *coverButton;
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) NSIndexPath *selectedIndex;
@property (nonatomic, assign, getter=isAnimating) BOOL animating;
@property (nonatomic, assign) BOOL hasMoved;
@end

@implementation MailFolderViewController

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
    [self loadMailFolder];
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
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.hasMoved&&self.moveSuccessBlock) {
            self.moveSuccessBlock();
        }
    }];
}

#pragma mark TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell= [tableView dequeueReusableCellWithIdentifier:reuseableID];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseableID];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    CYFolder *folder = self.dataArray[indexPath.row];
    cell.textLabel.text = NSLocalizedString([folder.name uppercaseString], nil);
    
    if (self.selectedIndex == indexPath) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath;
    [tableView reloadData];
}

#pragma mark - Event Response
- (IBAction)confirmBtnClicked{
    if(!self.selectedIndex){
        [self showToast:MsgConfirmFolder];
        return;
    }
    [self moveFolder];
}

#pragma mark - Network Methods
- (void)loadMailFolder{
    NSArray *folders = [self.folder.account.folders allObjects];
    NSMutableArray *array = [NSMutableArray array];
    for (CYFolder *folder in folders) {
        if(![self.folder.path isEqualToString:folder.path]){
            [array addObject:folder];
        }
    }
    self.dataArray = [CYMailUtil sortFolders:array];
    
    [self.tableView reloadData];
    
}

- (void)moveFolder{
    CYFolder *folder = self.dataArray[self.selectedIndex.row];
    
    [self showHudWithMsg:@"邮件移动中...."];
    __weak typeof(self) weakSelf = self;
    [self.session moveMail:self.mail destFolder:folder.path success:^{
        [self hideHuds];
        self.hasMoved = YES;
        [[CYMailModelManager sharedCYMailModelManager]deleteMail:weakSelf.mail error:nil];
        [self fadeOutAnimate];
    } failure:^(NSError *error) {
        [self hideHuds];
        [weakSelf showToast:[NSString stringWithFormat:@"%@",error.userInfo[NSLocalizedDescriptionKey]]];
    }];
}

#pragma mark -Getters and Setters
- (NSArray *)dataArray{
    if(!_dataArray){
        _dataArray = [NSArray array];
    }
    return _dataArray;
}

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
            var.rowHeight =  44;
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
        titleLabel.text = MsgChooseFolder;
        titleLabel.textColor = UICOLOR(@"#2D4664");
        [headerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView.mas_top).offset(20);
            make.left.equalTo(headerView.mas_left);
            make.right.equalTo(headerView.mas_right);
            make.bottom.equalTo(headerView.mas_bottom);
        }];
        
        UIButton *congfirmButton = [[UIButton alloc]init];
        [congfirmButton setTitle:MsgConfirm forState:UIControlStateNormal];
        [congfirmButton setTitleColor:UICOLOR(@"#2D4664") forState:UIControlStateNormal];
        congfirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [congfirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:congfirmButton];
        [congfirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView.mas_top).offset(20);
            make.right.mas_equalTo(-15);
            make.width.mas_equalTo(50);
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

- (CYMailSession *)session{
    return [[CYMailSessionManager sharedCYMailSessionManager]getSessionWithUsername:self.folder.account.username];
}

@end
