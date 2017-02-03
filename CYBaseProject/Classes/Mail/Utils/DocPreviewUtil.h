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
+ (NSString *)filePathWithFilename:(NSString *)filename directory:(NSString *)directory;

- (BOOL)previewDocOfPath:(NSString *)path controller:(UIViewController *)controller completion:(void (^)())completion;
- (BOOL)previewInOtherAppOfPath:(NSString *)path controller:(UIViewController *)controller completion:(void (^)())completion;

@end
