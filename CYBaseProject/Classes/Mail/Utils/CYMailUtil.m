//
//  CYMailUtil.m
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/13.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import "CYMailUtil.h"
#import "CYFolder.h"
#import "CYMail.h"
#import <MailCore/MailCore.h>
#import "YYSandBoxUtil.h"

@implementation CYMailUtil

/**
 Sort folder 邮箱目录排序
 
 @param folderArray 邮箱目录列表
 */
+ (NSArray *)sortFolders:(NSArray *)folders{
    
    NSArray *sortedFolders = [folders sortedArrayUsingComparator:^NSComparisonResult(CYFolder  *_Nonnull obj1, CYFolder  *_Nonnull obj2) {
        NSComparisonResult result;
        if ([[obj1.path uppercaseString]isEqualToString:@"INBOX"]) {
            return NSOrderedAscending;
        }
        if ([[obj2.path uppercaseString]isEqualToString:@"INBOX"]) {
            return NSOrderedDescending;
        }
        result = [obj1.name compare:obj2.name];
        
        return result;
    }];
    
    return sortedFolders;
    
}

/**
 Whether is trash box 是否"已删除"文件夹

 @param folder 文件夹
 @return
 */
+ (BOOL)isTrashFolder:(CYFolder *)folder{
    
    //According to flag
    BOOL flagJudgement =[folder.flags integerValue] & MCOIMAPFolderFlagTrash;
    //According to name
    BOOL nameJudgement = [folder.name isEqualToString:@"已删除"]||[[folder.name uppercaseString] isEqualToString:@"TRASH"]||[[folder.name uppercaseString] isEqualToString:@"JUNK"];
    
    return flagJudgement||nameJudgement;
}

/**
 Whether is sent box 是否"已发送"文件夹
 
 @param folder 文件夹
 @return
 */
+ (BOOL)isSentFolder:(CYFolder *)folder{
    
    //According to flag
    BOOL flagJudgement =[folder.flags integerValue] & MCOIMAPFolderFlagSentMail;
    //According to name
    BOOL nameJudgement = [folder.name isEqualToString:@"已发送"]||[[folder.name uppercaseString] isEqualToString:@"SENT"];
    
    return flagJudgement||nameJudgement;
}

/**
 Get local attachment folder of mail 本地附件缓存路径

 @param mail 邮件
 @return local path of attachment folder 
 */
+ (NSString *)attachmentFolderOfMail:(CYMail *)mail{
    
    NSString *mailAttachmentParentFolder = [[YYSandBoxUtil getDocumentDirectory] stringByAppendingPathComponent:@"MailAttachment"];
    [YYSandBoxUtil createIfNotExistsFolder:mailAttachmentParentFolder];
    
    NSString *mailAttachmentFolder = [mailAttachmentParentFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@",mail.account,mail.folderPath,mail.uid]];
    [YYSandBoxUtil createIfNotExistsFolder:mailAttachmentFolder];
    
    return mailAttachmentFolder;
}

/**
 Generate content of reply/forward mail 生成回复/转发用正文
 
 @param mail 邮件
 @return content of reply/forward mail
 */
+ (NSMutableAttributedString *)generateReplyContent:(CYMail *)mail{
    
    if (!mail) return nil;
    
    NSMutableAttributedString *forwardContent = [[NSMutableAttributedString alloc]init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSMutableString *forwardHeader = [NSMutableString stringWithString:@"\n\n\n\n\n"];
    [forwardHeader appendString:[NSString stringWithFormat:@"------------%@------------\n",MsgOrigin]];
    [forwardHeader appendString:[NSString stringWithFormat:@"%@:%@\n",MsgFrom,mail.fromAddress]];
    [forwardHeader appendString:[NSString stringWithFormat:@"%@:%@\n",MsgDate,[formatter stringFromDate:mail.sendDate]]];
    [forwardHeader appendString:[NSString stringWithFormat:@"%@:%@\n",MsgTo,mail.to]];
    [forwardHeader appendString:[NSString stringWithFormat:@"%@:%@\n",MsgSubject,mail.subject]];
    [forwardHeader appendString:@"*********************************\n"];
    
    [forwardContent appendAttributedString:[[NSAttributedString alloc]initWithString:forwardHeader attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}]];
    
    NSAttributedString *forwardBody = [[NSAttributedString alloc] initWithData:[mail.content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    [forwardContent appendAttributedString:forwardBody];
    
    return forwardContent;
}

@end
