//
//  CYMailSession.h
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/12.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

typedef NS_OPTIONS(NSInteger, CYMailConnectionType) {
    CYMailConnectionTypeClear             = 1 << 0,
    CYMailonnectionTypeStartTLS           = 1 << 1,
    CYMailConnectionTypeTLS               = 1 << 2,
};

@class CYFolder,MCOIMAPFolderStatus,CYMail,CYAttachment,CYTempAttachment;

@interface CYMailSession : NSObject

@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *imapHostname;
@property (nonatomic, assign) NSUInteger imapPort;
@property (nonatomic, assign) CYMailConnectionType imapConnectionType;
@property (nonatomic, copy) NSString *smtpHostname;
@property (nonatomic, assign) NSUInteger smtpPort;
@property (nonatomic, assign) NSInteger smtpAuthType;

/**
 Verify the mail account(Login) 邮箱验证（登陆）
 
 @param success 成功回调
 @param failure 失败回调
 */
- (void)checkAccountSuccess:(void (^)())success failure:(void (^)(NSError *  error))failure;

/**
 Get all folders of mail account 获取邮箱目录
 
 @param success 成功回调
 @param failure 失败回调
 */
- (void)fetchAllFoldersSuccess:(void (^)(NSArray<CYFolder *> *folders))success failure:(void (^)(NSError *  error))failure;

/**
 Query folder status(like unseen) 获取目录信息(未读数)
 
 @param folder 目录path
 @param success 成功回调
 @param failure 失败回调
 */
- (void)folderStatusOfFolder:(NSString *)folder success:(void (^)(MCOIMAPFolderStatus *status))success failure:(void (^)(NSError *  error))failure;

/**
 Get mail list by uid range 以uid范围获取邮件
 
 @param folderPath 目录路径
 @param startUid 起始邮件Uid
 @param length uid跨度
 @param success 成功回调
 @param failure 失败回调
 */
- (void)fetchMailsOfFolder:(CYFolder *)folder startUid:(NSUInteger)startUid length:(NSUInteger)length success:(void (^)(NSArray<CYMail *> *mails))success failure:(void (^)(NSError *error))failure;

/**
 Sync and update the mails status 同步更新邮件状态
 
 @param folder 邮件目录
 @param success 成功回调
 @param failure 失败回调
 */
- (void)syncMailWith:(CYFolder *)folder success:(void (^)())success failure:(void (^)(NSError *error))failure;

/**
 Get mail content in html  获取邮件HTML正文
 
 @param mail 邮件对象
 @param success 成功回调
 @param failure 失败回调
 */
- (void)fetchHtmlBodyWithMail:(CYMail *)mail success:(void (^)(NSString *htmlBody))success failure:(void (^)(NSError *  error))failure;

/**
 Download attachment 下载附件
 
 @param attachment 附件
 @param downloadPath 本地路径
 @param success 成功回调
 @param failure 失败回调
 @param progress 进度回调
 */
- (void)downloadAttachment:(CYAttachment *)attachment downloadPath:(NSString *)downloadPath success:(void (^)())success failure:(void (^)(NSError *  error))failure progress:(void (^)(NSInteger current, NSInteger maximum))progress;

/**
 Delete Mail. if the mail is in trash box, delete directly. if not, move to trash box 删除邮件,如果邮件已经在”已删除“，直接删除，否则移动至“已删除”
 
 @param mail 邮件
 @param success 成功回调
 @param failure 失败回调
 */
- (void)deleteMail:(CYMail *)mail inFolder:(CYFolder *)folder success:(void (^)())success failure:(void (^)(NSError *  error))failure;

/**
 Delete Mail Directly 直接删除邮件
 
 @param uid uid
 @param folderPath 目录路径
 @param success 成功回调
 @param failure 失败回调
 */
- (void)deleteMailDirectlyWithUid:(NSUInteger)uid folerPath:(NSString *)folderPath success:(void (^)())success failure:(void (^)(NSError *))failure;

/**
 Move mail to other folder 邮件移动
 
 @param mail 邮件
 @param destFolder 目标目录
 @param success 成功回调
 @param failure 失败回调
 */
- (void)moveMail:(CYMail *)mail destFolder:(NSString *)destFolder success:(void (^)())success failure:(void (^)(NSError *  error))failure;

/**
 Update mail status to seen 标记邮件为已读
 
 @param mail 邮件
 @param success 成功回调
 @param failure 失败回调
 */
- (void)updateMailAsSeen:(CYMail *)mail success:(void (^)())success failure:(void (^)(NSError *  error))failure;

/**
 Send mail 发送邮件
 
 @param subject 主题
 @param content 内容
 @param toArray 收件人列表
 @param ccArray 抄送人列表
 @param bccArray 密送人列表
 @param attachments 附件列表
 @param originMail(for attatchments) 原始邮件(获取附件用)
 @param success 成功回调
 @param failure 失败回调
 @param progress 进度回调
 */
- (void)sendMailWithSubject:(NSString *)subject content:(NSString *)content toArray:(NSArray *)toArray ccArray:(NSArray *)ccArray bccArray:(NSArray *)bccArray attachmentArray:(NSArray<CYTempAttachment *> *)attachments originMail:(CYMail *)originMail success:(void (^)())success failure:(void (^)(NSError *  error))failure progress:(void (^)(NSInteger current, NSInteger maximum))progress;

@end
