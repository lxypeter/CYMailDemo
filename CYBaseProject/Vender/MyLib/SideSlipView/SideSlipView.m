//
//  SideSlipView.m
//  LoveMarket
//
//  Created by 段晓冬 on 15/8/10.
//  Copyright (c) 2015年 ztesoft. All rights reserved.
//

#import "SideSlipView.h"
#import <Accelerate/Accelerate.h>

@interface SideSlipView () {
    /**
     *  标识侧滑组件是否打开
     */
    BOOL isOpen;
    
    /**
     *  左右手势
     */
    UISwipeGestureRecognizer *_leftSwipe, *_rightSwipe;
    
    /**
     *  遮挡层图片
     */
    UIImageView *_blurImageView;
    
    /**
     *  遮挡层视图
     */
    UIView *_blurView;
    
    /**
     *  弹出侧滑组件的Controller
     */
    UIViewController *_sender;
    
    /**
     *  侧滑组件样式
     */
    SideSlipViewStyle _style;
}
@end

@implementation SideSlipView

#pragma mark - 用户使用错误的构造方法初始化提示用户
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(nil, @"please init with - initWithSender:sender");
    }
    return self;
}

#pragma mark - 初始化侧滑组件
/**
 *  初始化侧滑组件
 *
 *  @param sender 弹出侧滑组件的ControllerView
 *  @param style  侧滑组件的样式
 *
 *  @return 侧滑组件实例
 */
- (instancetype)initWithSender:(UIViewController*)sender andStyle:(SideSlipViewStyle)style {
    // 计算Frame
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect frame;
    
    // 从左侧弹出
    if (style == SideSlipViewStyleLeft || style == SideSlipViewStyleLeftAndBlurImg) {
        frame = CGRectMake(-kSlipViewWidth, 0, kSlipViewWidth, bounds.size.height);
    }
    
    // 从右侧弹出
    if (style == SideSlipViewStyleRight || style == SideSlipViewStyleRightAndBlurImg) {
        frame = CGRectMake(bounds.size.width, 0, kSlipViewWidth, bounds.size.height);
    }
    
    // 样式
    _style = style;
    
    // 创建
    self = [super initWithFrame:frame];
    if (self) {
        [self buildHeaderBar];
        [self buildViews:sender];
    }
    
    return self;
}

#pragma mark - 头部导航栏
/**
 *  头部导航栏
 */
- (void)buildHeaderBar {
    // 头部导航栏
    _headerNavigationBar = [[NSBundle mainBundle] loadNibNamed:@"SideSilpViewHeader" owner:self options:nil][0];
    _headerNavigationBar.frame = CGRectMake(0, 0, self.frame.size.width, 64);
    
    // 计算contentView的Frame
    _contentViewFrame = CGRectMake(0, 64, self.frame.size.width, self.frame.size.height - 64);
}

#pragma mark - 设置侧滑组件
/**
 *  设置侧滑组件
 *
 *  @param sender 弹出侧滑组件的Controller
 */
- (void)buildViews:(UIViewController *)sender {
    // 赋值
    _sender = sender;
    
    // 遮挡层的Frame
    CGRect blurViewFrame;
    
    // 手势
    // 从左侧弹出，向左侧滑动关闭侧滑组件
    if (_style == SideSlipViewStyleLeft || _style == SideSlipViewStyleLeftAndBlurImg)
    {
        // 创建手势
        _leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
        _leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [_sender.view addGestureRecognizer:_leftSwipe];
        
        // 遮挡层的Frame
        blurViewFrame = CGRectMake(kSlipViewWidth, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    
    // 从右侧弹出，向右侧滑动关闭侧滑组件
    if (_style == SideSlipViewStyleRight || _style == SideSlipViewStyleRightAndBlurImg)
    {
        // 创建手势
        _rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
        _rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        [_sender.view addGestureRecognizer:_rightSwipe];
        
        // 遮挡层的Frame
        CGFloat blurViewFrameX = 0 - [UIScreen mainScreen].bounds.size.width;
        blurViewFrame = CGRectMake(blurViewFrameX, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    
    // 玻璃特效
    if (_style == SideSlipViewStyleLeftAndBlurImg || _style == SideSlipViewStyleRightAndBlurImg) {
        _blurImageView = [[UIImageView alloc] initWithFrame:blurViewFrame];
        _blurImageView.userInteractionEnabled = NO;
        _blurImageView.alpha = 0;
        _blurImageView.backgroundColor = [UIColor blackColor];
        _blurImageView.layer.borderWidth = 5;
        _blurImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        
        // 添加至Controller的View中
        [self addSubview:_blurImageView];
    }
    
    // 普通遮挡
    if (_style == SideSlipViewStyleLeft || _style == SideSlipViewStyleRight) {
        _blurView = [[UIView alloc] initWithFrame:blurViewFrame];
        _blurView.userInteractionEnabled = NO;
        _blurView.alpha = 0;
        _blurView.backgroundColor = [UIColor blackColor];
        
        // 添加至Controller的View中
        [self addSubview:_blurView];
    }
    
    // 响应敲击事件的View
    _hideSideSlipBtn = [[UIButton alloc] init];
    CGFloat blurTapViewW = [UIScreen mainScreen].bounds.size.width - kSlipViewWidth;
    _hideSideSlipBtn.hidden = YES;
    //_hideSideSlipBtn.backgroundColor = [UIColor redColor];
    
    // 判断X值
    if (_style == SideSlipViewStyleLeft || _style == SideSlipViewStyleLeftAndBlurImg) {
        _hideSideSlipBtn.frame = CGRectMake(kSlipViewWidth, 0, blurTapViewW, [UIScreen mainScreen].bounds.size.height);
    }
    if (_style == SideSlipViewStyleRight || _style == SideSlipViewStyleRightAndBlurImg) {
        _hideSideSlipBtn.frame = CGRectMake(0, 0, blurTapViewW, [UIScreen mainScreen].bounds.size.height);
    }
    
    // 点击隐藏
    [_hideSideSlipBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 显示侧滑组件
/**
 *  显示侧滑组件
 *
 *  @param show 是否显示侧滑组件
 */
- (void)show:(BOOL)show {
    // 玻璃效果
    UIImage *image =  [self imageFromView:_sender.view];
    if (_style == SideSlipViewStyleLeftAndBlurImg || _style == SideSlipViewStyleRightAndBlurImg) {
        image =  [self imageFromView:_sender.view];
    }
    
    // 先设置不透明
    if (!isOpen) {
        if (_blurImageView) {
            _blurImageView.alpha = 1;
        }
        
        if (_blurView) {
            _blurView.alpha = 1;
        }
    }
    
    // 侧滑组件的X
    CGFloat sideSlipX = 0;
    // 从左侧显示
    if (_style == SideSlipViewStyleLeft || _style == SideSlipViewStyleLeftAndBlurImg)
    {
        sideSlipX = show ? 0 : -kSlipViewWidth;
    }
    // 从右侧显示
    if (_style == SideSlipViewStyleRight || _style == SideSlipViewStyleRightAndBlurImg)
    {
        
        sideSlipX = show ? [UIScreen mainScreen].bounds.size.width - kSlipViewWidth :  [UIScreen mainScreen].bounds.size.width;
    }
    
    // 动画滑出效果
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(sideSlipX, 0, self.frame.size.width, self.frame.size.height);
        if(!isOpen){
            if (_blurImageView) {
                _blurImageView.image = image;
                _blurImageView.image = [self blurryImage:_blurImageView.image withBlurLevel:0.1];
            }
            
            if (_blurView) {
                _blurView.alpha = 0.5;
            }
        }
    } completion:^(BOOL finished) {
        isOpen = show;
        _hideSideSlipBtn.hidden = NO;
        if(!isOpen){
            if (_blurImageView) {
                _blurImageView.alpha = 0;
                _blurImageView.image = nil;
            }
            
            if (_blurView) {
                _blurView.alpha = 0;
            }
            _hideSideSlipBtn.hidden = YES;
        }
    }];
    
}

#pragma mark - 显示侧滑组件
/**
 *  显示侧滑组件
 */
- (void)show {
    if (_sender.navigationController.navigationBar) {
        [_sender.navigationController setNavigationBarHidden:YES animated:YES];
    }
    if (_sender.tabBarController.tabBar&&self.hasTabBar) {
        _sender.tabBarController.tabBar.hidden = YES;
    }
    [self show:YES];
}

#pragma mark - 隐藏侧滑组件
/**
 *  隐藏侧滑组件
 */
- (void)hide {
    if (_sender.navigationController.navigationBar) {
        [_sender.navigationController setNavigationBarHidden:NO animated:YES];
    }
    if (_sender.tabBarController.tabBar&&self.hasTabBar) {
        _sender.tabBarController.tabBar.hidden = NO;
    }
    [self show:NO];
}

#pragma mark - 快捷显示/隐藏侧滑组件
/**
 *  快捷显示/隐藏侧滑组件
 */
- (void)switchMenu {
    if (isOpen) {
        if (_sender.navigationController.navigationBar) {
            [_sender.navigationController setNavigationBarHidden:NO animated:YES];
        }
        if (_sender.tabBarController.tabBar) {
            _sender.tabBarController.tabBar.hidden = NO;
        }
    } else {
        if (_sender.navigationController.navigationBar) {
            [_sender.navigationController setNavigationBarHidden:YES animated:YES];
        }
        if (_sender.tabBarController.tabBar&&self.hasTabBar) {
            _sender.tabBarController.tabBar.hidden = YES;
        }
    }
    [self show:!isOpen];
}

#pragma mark - 显示侧滑组件中的内容
/**
 *  显示侧滑组件中的内容
 *
 *  @param contentView 侧滑组件中要显示的内容
 */
- (void)setContentView:(UIView*)contentView {
    if (_headerNavigationBar) {
        [self addSubview:_headerNavigationBar];
    }
    
    // 判断是否为nil
    if (contentView) {
        _contentView = contentView;
    }
    
    // 计算contentView的Frame
    _contentView.frame = self.contentViewFrame;
    
    // 添加至Controller的View中
    [self addSubview:_contentView];
}

#pragma mark - 遮挡层图片方法
#pragma mark - 创建遮挡层方法
/**
 *  创建遮挡层方法
 *
 *  @param theView 弹出侧滑组件Controller中的View
 *
 *  @return View的截图
 */
- (UIImage *)imageFromView:(UIView *)theView {
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

#pragma mark - 返回磨砂效果图片
/**
 *  返回磨砂效果图片
 *
 *  @param image View截图
 *  @param blur  清晰度
 *
 *  @return 返回效果图片
 */
- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if ((blur < 0.0f) || (blur > 1.0f)) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

#pragma mark - 重写setter方法设置导航栏样式
/**
 *  设置导航栏样式
 *
 *  @param sideSlipHeaderStyle 导航栏样式
 */
- (void)setSideSlipHeaderStyle:(SideSlipHeaderStyle)sideSlipHeaderStyle {
    // 不需要左右按钮
    if (sideSlipHeaderStyle == SideSlipHeaderButtonNone) {
        self.leftButtonItem.title = @"";
        self.leftButtonItem.enabled = NO;
        self.rightButtonItem.title = @"";
        self.rightButtonItem.enabled = NO;
    }
    
    // 只需要左边按钮
    if (sideSlipHeaderStyle == SideSlipHeaderButtonLeft) {
        self.leftButtonItem.title = @"取消";
        self.leftButtonItem.enabled = YES;
        self.rightButtonItem.title = @"";
        self.rightButtonItem.enabled = NO;
    }
    
    // 只需要右边按钮
    if (sideSlipHeaderStyle == SideSlipHeaderButtonRight) {
        self.leftButtonItem.title = @"";
        self.leftButtonItem.enabled = NO;
        self.rightButtonItem.title = @"确定";
        self.rightButtonItem.enabled = YES;
    }
    
    // 左右按钮都需要
    if (sideSlipHeaderStyle == SideSlipHeaderButtonAll) {
        self.leftButtonItem.title = @"取消";
        self.leftButtonItem.enabled = YES;
        self.rightButtonItem.title = @"确定";
        self.rightButtonItem.enabled = YES;
    }
}

#pragma mark - 显示侧滑组件导航栏标题
- (void)setTitle:(NSString*)title{
    
    _title = title;
    
    UINavigationItem *navigationItem = [_headerNavigationBar items][0];
    navigationItem.title = title;
    
}

#pragma mark - 导航栏左侧按钮被点击
/**
 *  导航栏左侧按钮被点击
 *
 *  @param sender 点击的UIBarButtonItem
 */
- (IBAction)leftButtonItemClick:(UIBarButtonItem *)sender {
    // 调用代理方法
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelBtnClickWithSideSlipView:andButtonItem:)]) {
        // 取消
        [self.delegate cancelBtnClickWithSideSlipView:self andButtonItem:self.leftButtonItem];
    }
    
    // 隐藏滑动组件
    [self hide];
}

#pragma mark - 导航栏右侧按钮被点击
/**
 *  导航栏右侧按钮被点击
 *
 *  @param sender 点击的UIBarButtonItem
 */
- (IBAction)rightButtonItemClick:(UIBarButtonItem *)sender {
    // 调用代理方法
    if (self.delegate && [self.delegate respondsToSelector:@selector(okBtnClickWithSideSlipView:andButtonItem:)]) {
        // 确定
        [self.delegate okBtnClickWithSideSlipView:self andButtonItem:self.rightButtonItem];
    }
    
    // 隐藏滑动组件
    [self hide];
}
@end