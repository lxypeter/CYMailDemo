//
//  AttachmentViewController.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/28.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "CYBaseMailViewController.h"

@class ZTEMailAttachment;
@interface MailAttachmentViewController : CYBaseMailViewController

@property (nonatomic, strong) NSString *ownerAddress;
@property (nonatomic, strong) NSString *folderPath;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, strong) UIViewController *parentController;
@property (nonatomic, strong) NSArray<ZTEMailAttachment *> *attachments;

- (instancetype)initWithOwnerAddress:(NSString *)ownerAddress folderPath:(NSString *)folderPath uid:(NSInteger)uid attachments:(NSArray<ZTEMailAttachment *> *)attachments parentController:(UIViewController *)parentController;

@end
