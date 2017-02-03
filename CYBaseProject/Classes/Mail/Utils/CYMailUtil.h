//
//  CYMailUtil.h
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/13.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CYFolder,CYMail;
@interface CYMailUtil : NSObject

/**
 Sort folder 邮箱目录排序
 
 @param folderArray 邮箱目录列表
 */
+ (NSArray *)sortFolders:(NSArray *)folders;

/**
 Whether is trash box 是否"已删除"文件夹
 
 @param folder 文件夹
 @return
 */
+ (BOOL)isTrashFolder:(CYFolder *)folder;

/**
 Whether is sent box 是否"已发送"文件夹
 
 @param folder 文件夹
 @return
 */
+ (BOOL)isSentFolder:(CYFolder *)folder;

/**
 Get local attachment folder of mail 本地附件缓存路径
 
 @param mail 邮件
 @return local path of attachment folder
 */
+ (NSString *)attachmentFolderOfMail:(CYMail *)mail;

/**
 Generate content of reply/forward mail 生成回复/转发用正文

 @param mail 邮件
 @return content of reply/forward mail
 */
+ (NSMutableAttributedString *)generateReplyContent:(CYMail *)mail;

@end
