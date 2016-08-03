//
//  ZTEIMAPSessionUtil.h
//  HNPositionAsst
//
//  Created by Peter Lee on 16/7/11.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

typedef NS_OPTIONS(NSInteger, ZTEMailConnectionType) {
    /** Clear-text connection for the protocol.*/
    ZTEMailConnectionTypeClear             = 1 << 0,
    /** Clear-text connection at the beginning, then switch to encrypted connection using TLS/SSL*/
    /** on the same TCP connection.*/
    ZTEMailonnectionTypeStartTLS          = 1 << 1,
    /** Encrypted connection using TLS/SSL.*/
    ZTEMailConnectionTypeTLS               = 1 << 2,
};

typedef NS_OPTIONS(NSInteger, ZTEMailFolderFlag) {
    ZTEMailFolderFlagNone        = 0,
    /** \Marked*/
    ZTEMailFolderFlagMarked      = 1 << 0,
    /** \Unmarked*/
    ZTEMailFolderFlagUnmarked    = 1 << 1,
    /** \NoSelect: When a folder can't be selected.*/
    ZTEMailFolderFlagNoSelect    = 1 << 2,
    /** \NoInferiors: When the folder has no children.*/
    ZTEMailFolderFlagNoInferiors = 1 << 3,
    /** \Inbox: When the folder is the inbox.*/
    ZTEMailFolderFlagInbox       = 1 << 4,
    /** \Sent: When the folder is the sent folder.*/
    ZTEMailFolderFlagSentMail    = 1 << 5,
    /** \Starred: When the folder is the starred folder*/
    ZTEMailFolderFlagStarred     = 1 << 6,
    /** \AllMail: When the folder is all mail.*/
    ZTEMailFolderFlagAllMail     = 1 << 7,
    /** \Trash: When the folder is the trash.*/
    ZTEMailFolderFlagTrash       = 1 << 8,
    /** \Drafts: When the folder is the drafts folder.*/
    ZTEMailFolderFlagDrafts      = 1 << 9,
    /** \Spam: When the folder is the spam folder.*/
    ZTEMailFolderFlagSpam        = 1 << 10,
    /** \Important: When the folder is the important folder.*/
    ZTEMailFolderFlagImportant   = 1 << 11,
    /** \Archive: When the folder is archive.*/
    ZTEMailFolderFlagArchive     = 1 << 12,
    /** \All: When the folder contains all mails, similar to \AllMail.*/
    ZTEMailFolderFlagAll         = MCOIMAPFolderFlagAllMail,
    /** \Junk: When the folder is the spam folder.*/
    ZTEMailFolderFlagJunk        = MCOIMAPFolderFlagSpam,
    /** \Flagged: When the folder contains all the flagged emails.*/
    ZTEMailFolderFlagFlagged     = MCOIMAPFolderFlagStarred,
    /** Mask to identify the folder */
    ZTEMailFolderFlagFolderTypeMask = ZTEMailFolderFlagInbox | ZTEMailFolderFlagSentMail | ZTEMailFolderFlagStarred | ZTEMailFolderFlagAllMail |
    ZTEMailFolderFlagTrash| ZTEMailFolderFlagDrafts | ZTEMailFolderFlagSpam | ZTEMailFolderFlagImportant | ZTEMailFolderFlagArchive,
};

@interface ZTESimpleFolderModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) NSInteger flags;

@end

@interface ZTEAttachmentModel : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) NSData *fileData;
+ (ZTEAttachmentModel *)attachmentModelWithFileName:(NSString *)fileName fileData:(NSData *)fileData;
- (ZTEAttachmentModel *)initWithFileName:(NSString *)fileName fileData:(NSData *)fileData;

@end

@class MCOIMAPSession;
@interface ZTEMailSessionUtil : NSObject

@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *imapHostname;
@property (nonatomic, assign) NSInteger imapPort;
@property (nonatomic, assign) ZTEMailConnectionType imapConnectionType;
@property (nonatomic, copy) NSString *smtpHostname;
@property (nonatomic, assign) NSInteger smtpPort;
@property (nonatomic, assign) NSInteger smtpAuthType;

+ (ZTEMailSessionUtil *)shareUtil;

/**
 *  @author CY.Lee, 16-07-12 15:07:54
 *
 *  获取邮箱文件夹中文名
 *
 *  @param folderName 原始名
 */
+ (NSString *)chnNameOfFolder:(NSString *)folderName;

/**
 *  @author CY.Lee, 16-07-12 10:07:43
 *
 *  清空Session
 */
- (void)clear;

/**
 *  @author CY.Lee, 16-07-11 15:07:08
 *
 *  邮箱地址检查（登陆）
 *
 */
- (void)checkAccountSuccess:(void (^)())success failure:(void (^)(NSError *  error))failure;

/**
 *  @author CY.Lee, 16-07-12 11:07:02
 *
 *  获取邮箱目录
 *
 */
- (void)fetchAllFoldersSuccess:(void (^)(NSArray<ZTESimpleFolderModel *> *folders))success failure:(void (^)(NSError *  error))failure;

/**
 *  @author CY.Lee, 16-07-12 11:07:43
 *
 *  获取目录信息
 *
 *  @param folderName 目录名
 */
- (void)folderStatusOfFolder:(NSString *)folder success:(void (^)(MCOIMAPFolderStatus *status))success failure:(void (^)(NSError *  error))failure;

/**
 *  @author CY.Lee, 16-07-12 15:07:32
 *
 *  以index获取邮件
 *
 *  @param folderName 目录名
 *  @param location   邮件location
 *  @param size       获取数目
 */
- (void)fetchMessagesWithFolder:(NSString *)folderName location:(NSUInteger)location size:(NSUInteger)size success:(void (^)(NSArray *messages))success failure:(void (^)(NSError *  error))failure;

/**
 *  @author CY.Lee, 16-07-13 10:07:38
 *
 *  以uid范围获取邮件
 *
 *  @param folderName 目录名
 *  @param startUid   起始uid
 *  @param length     uid范围
 */
- (void)fetchMessagesWithFolder:(NSString *)folderName startUid:(NSUInteger)startUid length:(NSUInteger)length success:(void (^)(NSArray *messages))success failure:(void (^)(NSError *  error))failure;

/**
 *  @author CY.Lee, 16-07-13 09:07:48
 *
 *  获取邮件HTML正文
 *
 *  @param message 邮件对象
 *  @param folder  目录名
 */
- (void)getHtmlBodyWithMessage:(MCOIMAPMessage *)message folder:(NSString *)folder success:(void (^)(NSString *htmlBody))success failure:(void (^)(NSError *error))failure;

/**
 *  @author CY.Lee, 16-07-14 16:07:48
 *
 *  获取邮件HTML正文(根据uid)
 *
 *  @param uid     邮件uid
 *  @param folder  目录名
 */
- (void)getHtmlBodyWithUid:(NSInteger)uid folder:(NSString *)folder success:(void (^)(NSString *htmlBody))success failure:(void (^)(NSError *error))failure;

/**
 *  @author CY.Lee, 16-07-13 17:07:24
 *
 *  标记邮件为已读
 *
 *  @param folder     目录名
 *  @param uid        邮件uid
 */
- (void)updateMailAsSeenWithFolder:(NSString *)folder uid:(NSInteger)uid success:(void (^)())success failure:(void (^)(NSError *  error))failure;

/**
 *  @author CY.Lee, 16-07-13 17:07:32
 *
 *  删除邮件
 *
 *  @param folder  目录名
 *  @param uid     邮件uid
 */
- (void)deleteMailWithFolder:(NSString *)folder uid:(NSInteger)uid success:(void (^)())success failure:(void (^)(NSError *  error))failure;

/**
 *  @author CY.Lee, 16-07-14 16:07:07
 *
 *  下载附件
 *
 *  @param folder       目录名
 *  @param uid          邮件uid
 *  @param partid       附件id
 *  @param downloadPath 保存路径
 */
- (void)fetchMessageAttachmentWithFolder:(NSString *)folder uid:(NSInteger)uid partID:(NSString *)partid downloadPath:(NSString *)downloadPath success:(void (^)())success failure:(void (^)(NSError *  error))failure progress:(void (^)(NSInteger current, NSInteger maximum))progress;

/**
 *  @author CY.Lee, 16-07-18 10:07:40
 *
 *  邮件移动
 *
 *  @param folder     邮件目录
 *  @param uid        邮件uid
 *  @param destFolder 目标目录
 */
- (void)moveMessagesWithFolder:(NSString *)folder uid:(NSInteger)uid destFolder:(NSString *)destFolder success:(void (^)())success failure:(void (^)(NSError *  error))failure;

/**
 *  @author CY.Lee, 16-07-18 15:07:06
 *
 *  发送邮件
 *
 *  @param subject  主题
 *  @param content  内容
 *  @param toArray  收件人列表
 *  @param ccArray  抄送人列表
 *  @param bccArray 密送人列表
 *  @param images   图片附件列表
 *  @param uid      转发回复uid
 *  @param folder   转发回复目录名
 */
- (void)sendMailWithSubject:(NSString *)subject content:(NSString *)content toArray:(NSArray *)toArray ccArray:(NSArray *)ccArray bccArray:(NSArray *)bccArray imageAttachmentArray:(NSArray<ZTEAttachmentModel *> *)images uid:(NSInteger)uid folder:(NSString *)folder success:(void (^)())success failure:(void (^)(NSError *  error))failure progress:(void (^)(NSInteger current, NSInteger maximum))progress;

@end
