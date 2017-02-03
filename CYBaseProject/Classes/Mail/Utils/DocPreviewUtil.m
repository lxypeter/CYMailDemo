//
//  DocPreviewUtil.m
//  GXMoblieOA
//
//  Created by Peter Lee on 16/5/13.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "DocPreviewUtil.h"

typedef void(^DocPreviewUtilComplete)();

@interface DocPreviewUtil () <UIDocumentInteractionControllerDelegate>

@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, copy) DocPreviewUtilComplete completion;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation DocPreviewUtil

+ (DocPreviewUtil *)shareUtil{
    static DocPreviewUtil *util;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[DocPreviewUtil alloc]init];
    });
    return util;
}

+ (NSString *)filePathWithFilename:(NSString *)filename directory:(NSString *)directory{
    
    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:directory];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:folderPath isDirectory:&isDir]) {
        
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString *filePath = [folderPath stringByAppendingPathComponent:filename];
    
    return filePath;
}

- (BOOL)previewDocOfPath:(NSString *)path controller:(UIViewController *)controller completion:(void (^)())completion{
    
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
    documentController.delegate = self;
    self.controller = controller;
    self.completion = completion;
    return [documentController presentPreviewAnimated:YES];
}

- (BOOL)previewInOtherAppOfPath:(NSString *)path controller:(UIViewController *)controller completion:(void (^)())completion{
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
    self.documentController.delegate = self;
    self.controller = controller;
    self.completion = completion;
    return [self.documentController presentOpenInMenuFromRect:CGRectZero inView:controller.view animated:YES];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self.controller;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller{
    if (self.completion) {
        self.completion();
    }
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    if (self.completion) {
        self.completion();
    }
}

@end
