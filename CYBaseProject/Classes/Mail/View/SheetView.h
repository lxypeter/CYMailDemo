//
//  SheetView.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/1.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SheetView : UIView
/**
 *  @author YYang, 16-03-23 15:03:10
 *
 *  底部动画弹出有遮盖层的 view,点击遮盖层可隐藏
 *
 *  @param contentView 将要弹出的 view
 *  @param superView   在哪个view 上弹出 一般是 self.view
 *
 *  @return  sheetView
 */
+(instancetype)sheetViewWithContentView:(UIView *)contentView andSuperview:(UIView *)superView;
-(instancetype)initWithContentView:(UIView *)contentView andSuperview:(UIView *)superView;
/**
 *  @author YYang, 16-03-23 15:03:47
 *
 *  展示 sheetView
 */
-(void)showActionSheet;
@end
