//
//  DocPreviewUtil.h
//  GXMoblieOA
//
//  Created by Peter Lee on 16/5/13.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocPreviewUtil : NSObject

+ (DocPreviewUtil *)shareUtil;
- (void)previewDocOfPath:(NSString *)path controller:(UIViewController *)controller;

@end
