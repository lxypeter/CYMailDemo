//
//  ZTEIMAPSessionUtil.m
//  HNPositionAsst
//
//  Created by Peter Lee on 16/7/11.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "ZTEMailSessionUtil.h"
#import <MailCore/MailCore.h>

@implementation ZTESimpleFolderModel

@end

@implementation ZTEAttachmentModel

+ (ZTEAttachmentModel *)attachmentModelWithFileName:(NSString *)fileName fileData:(NSData *)fileData{
    ZTEAttachmentModel *attachment = [[ZTEAttachmentModel alloc]initWithFileName:fileName fileData:fileData];
    return attachment;
}

- (ZTEAttachmentModel *)initWithFileName:(NSString *)fileName fileData:(NSData *)fileData{
    self = [super init];
    if (self) {
        _fileName = [fileName copy];
        _fileData = fileData;
    }
    return self;
}

@end

@interface ZTEMailSessionUtil ()

@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOSMTPSession *smtpSession;

@end

@implementation ZTEMailSessionUtil

#pragma mark - 单例
+ (ZTEMailSessionUtil *)shareUtil{

    static ZTEMailSessionUtil *util;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[ZTEMailSessionUtil alloc] init];
    });
    
    return util;
}

#pragma mark - 懒加载
- (MCOIMAPSession *)imapSession{
    if (!_imapSession) {
        _imapSession = [[MCOIMAPSession alloc] init];
    }
    return _imapSession;
}

- (MCOSMTPSession *)smtpSession{
    if (!_smtpSession) {
        _smtpSession = [[MCOSMTPSession alloc] init];
        _smtpSession.connectionType = MCOConnectionTypeClear;
    }
    return _smtpSession;
}

#pragma mark - setter
- (void)setImapHostname:(NSString *)imapHostname{
    _imapHostname = [imapHostname copy];
    self.imapSession.hostname = _imapHostname;
}

- (void)setImapPort:(NSInteger)imapPort{
    _imapPort = imapPort;
    self.imapSession.port = _imapPort;
}

- (void)setUsername:(NSString *)username{
    _username = [username copy];
    self.imapSession.username = _username;
    self.smtpSession.username = _username;
}

- (void)setPassword:(NSString *)password{
    _password = [password copy];
    self.imapSession.password = _password;
    self.smtpSession.password = _password;
}

- (void)setImapConnectionType:(ZTEMailConnectionType)imapConnectionType{
    _imapConnectionType = imapConnectionType;
    self.imapSession.connectionType = (MCOConnectionType)_imapConnectionType;
}

- (void)setSmtpHostname:(NSString *)smtpHostname{
    _smtpHostname = [smtpHostname copy];
    self.smtpSession.hostname = _smtpHostname;
}

- (void)setSmtpPort:(NSInteger)smtpPort{
    _smtpPort = smtpPort;
    self.smtpSession.port = _smtpPort;
}

- (void)setSmtpAuthType:(NSInteger)smtpAuthType{
    _smtpAuthType = smtpAuthType;
    self.smtpSession.authType = smtpAuthType;
}

#pragma mark - 邮箱方法
/**
 *  @author CY.Lee, 16-07-12 10:07:43
 *
 *  清空Session
 */
- (void)clear{
    _imapSession = nil;
    _smtpSession = nil;
}

#pragma mark IMAP
/**
 *  @author CY.Lee, 16-07-11 15:07:08
 *
 *  邮箱地址检查（登陆）
 *
 */
- (void)checkAccountSuccess:(void (^)())success failure:(void (^)(NSError *  error))failure{
    MCOIMAPOperation *operation = [self.imapSession checkAccountOperation];
    [operation start:^(NSError * _Nullable error) {
        if (error){
            NSLog(@"登陆失败 =====> %@",error);
            failure(error);
        }else{
            NSLog(@"登陆成功");
            success();
        }
    }];
}

/**
 *  @author CY.Lee, 16-07-12 11:07:02
 *
 *  获取邮箱目录
 *
 */
- (void)fetchAllFoldersSuccess:(void (^)(NSArray<ZTESimpleFolderModel *> *folders))success failure:(void (^)(NSError *  error))failure{
    __weak typeof(self) weakSelf = self;
    MCOIMAPFetchFoldersOperation *operation = [self.imapSession fetchAllFoldersOperation];
    [operation start:^(NSError * _Nullable error, NSArray * _Nullable folders) {
        if (error){
            NSLog(@"获取邮箱目录失败 =====> %@",error);
            failure(error);
        }else{
            NSLog(@"获取邮箱目录成功");
            NSMutableArray *array = [NSMutableArray array];
            for (MCOIMAPFolder *folder in folders) {
                ZTESimpleFolderModel *model = [[ZTESimpleFolderModel alloc]init];
                model.path = folder.path;
                model.name = [[weakSelf.imapSession defaultNamespace] componentsFromPath:folder.path][0];
                model.flags = folder.flags;
                [array addObject:model];
            }
            success(array);
        }
    }];
}

/**
 *  @author CY.Lee, 16-07-12 11:07:43
 *
 *  获取目录信息
 *
 *  @param folderName 目录名
 */
- (void)folderStatusOfFolder:(NSString *)folder success:(void (^)(MCOIMAPFolderStatus *status))success failure:(void (^)(NSError *  error))failure{
    MCOIMAPFolderStatusOperation *folderStatus = [self.imapSession folderStatusOperation:folder];
    [folderStatus start:^(NSError * _Nullable error, MCOIMAPFolderStatus * _Nullable status) {
        if (error){
            NSLog(@"获取邮箱目录%@信息失败 =====> %@",folder,error);
            failure(error);
        }else{
            NSLog(@"获取邮箱目录%@信息成功",folder);
            success(status);
        }
    }];
}

/**
 *  @author CY.Lee, 16-07-12 15:07:32
 *
 *  以index获取邮件
 *
 *  @param folderName 目录名
 *  @param location   邮件location
 *  @param size       获取数目
 */
- (void)fetchMessagesWithFolder:(NSString *)folderName location:(NSUInteger)location size:(NSUInteger)size success:(void (^)(NSArray *messages))success failure:(void (^)(NSError *  error))failure{

    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)

    (MCOIMAPMessagesRequestKindStructure | MCOIMAPMessagesRequestKindInternalDate |MCOIMAPMessagesRequestKindHeaderSubject | MCOIMAPMessagesRequestKindFlags |MCOIMAPMessagesRequestKindFullHeaders);

    MCOIndexSet *numberRange = [MCOIndexSet indexSetWithRange:MCORangeMake(location,size)];

    MCOIMAPFetchMessagesOperation *fetchOperation = [self.imapSession fetchMessagesByNumberOperationWithFolder:folderName requestKind:requestKind numbers:numberRange];

    [fetchOperation start:^(NSError * error,NSArray * fetchedMessages,MCOIndexSet * vanishedMessages) {

        if(error){
            NSLog(@"获取邮件列表失败 =====> %@", error);
            failure(error);
        }else{
            NSLog(@"获取邮件列表成功");
            success(fetchedMessages);
        }
    }];
}

/**
 *  @author CY.Lee, 16-07-13 10:07:38
 *
 *  以uid范围获取邮件
 *
 *  @param folderName 目录名
 *  @param startUid   起始uid
 *  @param length     uid范围
 */
- (void)fetchMessagesWithFolder:(NSString *)folderName startUid:(NSUInteger)startUid length:(NSUInteger)length success:(void (^)(NSArray *messages))success failure:(void (^)(NSError *  error))failure{
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    
    (MCOIMAPMessagesRequestKindStructure |MCOIMAPMessagesRequestKindInternalDate |MCOIMAPMessagesRequestKindHeaderSubject |MCOIMAPMessagesRequestKindFlags |MCOIMAPMessagesRequestKindFullHeaders);
    
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(startUid,length)];
    
    MCOIMAPFetchMessagesOperation *fetchOperation = [self.imapSession fetchMessagesOperationWithFolder:folderName requestKind:requestKind uids:uids];
    
    [fetchOperation start:^(NSError * error,NSArray * fetchedMessages,MCOIndexSet * vanishedMessages) {
        
        if(error){
            NSLog(@"获取邮件列表失败 =====> %@", error);
            failure(error);
        }else{
            NSLog(@"获取邮件列表成功");
            success(fetchedMessages);
        }
    }];
    
}

/**
 *  @author CY.Lee, 16-07-13 09:07:48
 *
 *  获取邮件HTML正文
 *
 *  @param message 邮件对象
 *  @param folder  目录名
 */
- (void)getHtmlBodyWithMessage:(MCOIMAPMessage *)message folder:(NSString *)folder success:(void (^)(NSString *htmlBody))success failure:(void (^)(NSError *  error))failure{
    
    MCOIMAPMessageRenderingOperation *operation = [self.imapSession htmlBodyRenderingOperationWithMessage:message folder:folder];
    [operation start:^(NSString * htmlString, NSError * error) {
        if(error){
            NSLog(@"获取正文失败 =====> %@", error);
            failure(error);
        }else{
            NSLog(@"获取正文成功");
            if ([NSString isBlankString:htmlString]) {
                htmlString = @"-";
            }
            success(htmlString);
        }
    }];
}

/**
 *  @author CY.Lee, 16-07-14 16:07:48
 *
 *  获取邮件HTML正文(根据uid)
 *
 *  @param uid     邮件uid
 *  @param folder  目录名
 */
- (void)getHtmlBodyWithUid:(NSInteger)uid folder:(NSString *)folder success:(void (^)(NSString *htmlBody))success failure:(void (^)(NSError *error))failure{
    
    [self fetchMessagesWithFolder:folder startUid:uid length:1 success:^(NSArray *messages) {

        [self getHtmlBodyWithMessage:messages[0] folder:folder success:^(NSString *htmlBody) {
            success(htmlBody);
        } failure:^(NSError *error) {
            failure(error);
        }];

    } failure:^(NSError *error) {
        failure(error);
    }];
}

/**
 *  @author CY.Lee, 16-07-13 17:07:24
 *
 *  标记邮件为已读
 *
 *  @param folder     目录名
 *  @param uid        邮件uid
 */
- (void)updateMailAsSeenWithFolder:(NSString *)folder uid:(NSInteger)uid success:(void (^)())success failure:(void (^)(NSError *  error))failure{
    MCOIMAPOperation *operation = [self.imapSession storeFlagsOperationWithFolder:folder uids:[MCOIndexSet indexSetWithIndex:uid] kind:MCOIMAPStoreFlagsRequestKindSet flags:MCOMessageFlagSeen];
    [operation start:^(NSError * error) {
        if(error){
            NSLog(@"标记已读失败 =====> %@", error);
            failure(error);
        }else{
            NSLog(@"标记已读成功");
            success();
        }
    }];
}

/**
 *  @author CY.Lee, 16-07-13 17:07:32
 *
 *  删除邮件
 *
 *  @param folder  目录名
 *  @param uid     邮件uid
 */
- (void)deleteMailWithFolder:(NSString *)folder uid:(NSInteger)uid success:(void (^)())success failure:(void (^)(NSError *  error))failure{
    MCOIMAPOperation *operation = [self.imapSession storeFlagsOperationWithFolder:folder uids:[MCOIndexSet indexSetWithIndex:uid] kind:MCOIMAPStoreFlagsRequestKindSet flags:MCOMessageFlagDeleted];
    [operation start:^(NSError * error) {
        
        if (error){
            NSLog(@"删除邮件失败 =====> %@", error);
            failure(error);
            return;
        }
        //添加成功之后对当前文件夹进行expunge操作
        MCOIMAPOperation *deleteOp = [self.imapSession expungeOperation:folder];
        [deleteOp start:^(NSError *error) {
            if(error){
                NSLog(@"删除邮件失败 =====> %@", error);
                failure(error);
            }else{
                NSLog(@"删除邮件成功");
                success();
            }
        }];
    }];
}

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
- (void)fetchMessageAttachmentWithFolder:(NSString *)folder uid:(NSInteger)uid partID:(NSString *)partid downloadPath:(NSString *)downloadPath success:(void (^)())success failure:(void (^)(NSError *  error))failure progress:(void (^)(NSInteger current, NSInteger maximum))progress{
    //附件下载
    MCOIMAPFetchContentOperation * op = [self.imapSession fetchMessageAttachmentOperationWithFolder:folder uid:(uint32_t)uid partID:partid encoding:MCOEncodingBase64];
    [op start:^(NSError * error, NSData * partData) {
        
        if (error) {
            NSLog(@"下载附件失败 =====> %@", error);
            failure(error);
        }

        if ([partData writeToFile:downloadPath atomically:YES]) {
            NSLog(@"保存附件成功");
            success();
        }else{
            NSLog(@"保存附件失败");
            failure(nil);
        }
    }];
    op.progress = ^(unsigned int current, unsigned int maximum){
        progress(current,maximum);
    };
}

/**
 *  @author CY.Lee, 16-07-18 10:07:40
 *
 *  邮件移动
 *
 *  @param folder     邮件目录
 *  @param uid        邮件uid
 *  @param destFolder 目标目录
 */
- (void)moveMessagesWithFolder:(NSString *)folder uid:(NSInteger)uid destFolder:(NSString *)destFolder success:(void (^)())success failure:(void (^)(NSError *  error))failure{
    
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(uid,1)];
    MCOIMAPCopyMessagesOperation *operation = [self.imapSession copyMessagesOperationWithFolder:folder uids:uids destFolder:destFolder];
    [operation start:^(NSError * _Nullable error, NSDictionary * _Nullable uidMapping) {
        
        if (error){
            NSLog(@"移动邮件失败 =====> %@", error);
            failure(error);
            return;
        }
        NSLog(@"移动邮件成功");
        success();
        [self deleteMailWithFolder:folder uid:uid success:^{
            
        } failure:^(NSError *error) {
            
        }];
        
    }];
}

#pragma mark SMTP
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
- (void)sendMailWithSubject:(NSString *)subject content:(NSString *)content toArray:(NSArray *)toArray ccArray:(NSArray *)ccArray bccArray:(NSArray *)bccArray imageAttachmentArray:(NSArray<ZTEAttachmentModel *> *)images uid:(NSInteger)uid folder:(NSString *)folder success:(void (^)())success failure:(void (^)(NSError *  error))failure progress:(void (^)(NSInteger current, NSInteger maximum))progress{
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    
    //发送人
    NSString *nickname = self.nickname;
    if ([NSString isBlankString:nickname]) {
        nickname = self.username;
    }
    MCOAddress *fromAdd = [MCOAddress addressWithDisplayName:nickname mailbox:self.username];
    [[builder header] setFrom:fromAdd];
    
    //收件人
    NSMutableArray *mutableListTo = [NSMutableArray array];
    for (NSString *to in toArray) {
        MCOAddress *toAdd = [MCOAddress addressWithDisplayName:to mailbox:to];
        [mutableListTo addObject:toAdd];
    }
    [[builder header] setTo:mutableListTo];
    
    //抄送人
    NSMutableArray *mutableListCc = [NSMutableArray array];
    for (NSString *cc in ccArray) {
        MCOAddress *ccAdd = [MCOAddress addressWithDisplayName:cc mailbox:cc];
        [mutableListCc addObject:ccAdd];
    }
    [[builder header] setCc:mutableListCc];
    
    //密送人
    NSMutableArray *mutableListBcc = [NSMutableArray array];
    for (NSString *bcc in bccArray) {
        MCOAddress *bccAdd = [MCOAddress addressWithDisplayName:bcc mailbox:bcc];
        [mutableListBcc addObject:bccAdd];
    }
    [[builder header] setBcc:mutableListBcc];
    
    //标题
    [[builder header] setSubject:[NSString stringWithCString:[subject UTF8String] encoding:NSUTF8StringEncoding]];
    
    [builder setHTMLBody:[content stringByReplacingOccurrencesOfString:@"\n"withString:@"<br/>"]];
    
    //附件
    NSMutableArray *mocattachmentList = [[NSMutableArray alloc]init];
    for (ZTEAttachmentModel *attachment in images) {
        
        NSString *fileName = attachment.fileName;
        
        MCOAttachment *mocattachment = [MCOAttachment attachmentWithData:attachment.fileData filename:fileName];
        
        [mocattachmentList addObject:mocattachment];
    }
    if (folder && uid) {//转发\回复附件
        MCOIMAPFetchContentOperation *fetchContentOp = [self.imapSession fetchMessageOperationWithFolder:folder uid:(uint32_t)uid];
        [fetchContentOp start:^(NSError * error, NSData * data) {
            
            if (error) {
                NSLog(@"发送邮件失败!=====》%@",error);
                failure(error);
                return;
            }
            
            MCOMessageParser *msgPareser = [MCOMessageParser messageParserWithData:data];
            for (MCOAttachment *attachment in msgPareser.attachments) {
                [mocattachmentList addObject:attachment];
            }
            
            builder.attachments = mocattachmentList;
            
            NSData *rfc822Data = [builder data];
            
            MCOSMTPSendOperation *sendOperation = [self.smtpSession sendOperationWithData:rfc822Data];
            [sendOperation start:^(NSError *error) {
                if(error) {
                    NSLog(@"发送邮件失败!=====》%@",error);
                    failure(error);
                } else {
                    NSLog(@"发送邮件成功!");
                    success();
                }
            }];
            sendOperation.progress =^(unsigned int current, unsigned int maximum){
                progress(current,maximum);
            };
        }];
    }else{

        builder.attachments = mocattachmentList;
        
        NSData *rfc822Data = [builder data];
        
        MCOSMTPSendOperation *sendOperation = [self.smtpSession sendOperationWithData:rfc822Data];
        [sendOperation start:^(NSError *error) {
            if(error) {
                NSLog(@"发送邮件失败!=====》%@",error);
                failure(error);
            } else {
                NSLog(@"发送邮件成功!");
                success();
            }
        }];
        sendOperation.progress =^(unsigned int current, unsigned int maximum){
            progress(current,maximum);
        };
    }
}

#pragma mark - 工具方法
/**
 *  @author CY.Lee, 16-07-12 15:07:54
 *
 *  获取邮箱文件夹中文名
 *
 *  @param folderName 原始名
 */
+ (NSString *)chnNameOfFolder:(NSString *)folderName{
    if ([[folderName uppercaseString]isEqualToString:@"INBOX"]) {
        return @"收件箱";
    }else if ([[folderName uppercaseString]isEqualToString:@"SENT"]){
        return @"已发送";
    }else if ([[folderName uppercaseString]isEqualToString:@"JUNK"]){
        return @"垃圾箱";
    }else if ([[folderName uppercaseString]isEqualToString:@"DRAFT"]){
        return @"草稿箱";
    }
    return folderName;
}

@end
