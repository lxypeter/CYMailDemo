//
//  UIColor+Category.h
//  gs_1210
//
//  Created by tangchenxue on 14/12/29.
//  Copyright (c) 2014年 areo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UICOLOR(A)  [UIColor colorWithHexString:A]

@interface UIColor (HexString)

#pragma mark 颜色转换，由颜色编码，转化为UIColor对象
- (id)initColorWithHexString:(NSString *)stringToConvert;

#pragma mark 颜色转换，由颜色编码，转化为UIColor对象
+ (id)colorWithHexString:(NSString *)stringToConvert;

@end
