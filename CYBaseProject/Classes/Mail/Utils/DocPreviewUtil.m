//
//  DocPreviewUtil.m
//  GXMoblieOA
//
//  Created by Peter Lee on 16/5/13.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "DocPreviewUtil.h"

@interface DocPreviewUtil () <UIDocumentInteractionControllerDelegate>

@property (nonatomic, weak) UIViewController *controller;

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

- (void)previewDocOfPath:(NSString *)path controller:(UIViewController *)controller{
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
    documentController.delegate = self;
    self.controller = controller;
    [documentController presentPreviewAnimated:YES];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self.controller;
}

@end
