//
//  CYMailSession.m
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/12.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import "CYMailSession.h"
#import "CYFolder.h"
#import "CYMail.h"
#import "CYMailModelManager.h"
#import "CYMailUtil.h"
#import "CYTempAttachment.h"

@interface CYMailSession ()

@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOSMTPSession *smtpSession;

@end

@implementation CYMailSession

#pragma mark - get/set method
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

- (void)setImapPort:(NSUInteger)imapPort{
    _imapPort = imapPort;
    self.imapSession.port = (unsigned int)_imapPort;
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

- (void)setImapConnectionType:(CYMailConnectionType)imapConnectionType{
    _imapConnectionType = imapConnectionType;
    self.imapSession.connectionType = (MCOConnectionType)_imapConnectionType;
}

- (void)setSmtpHostname:(NSString *)smtpHostname{
    _smtpHostname = [smtpHostname copy];
    self.smtpSession.hostname = _smtpHostname;
}

- (void)setSmtpPort:(NSUInteger)smtpPort{
    _smtpPort = smtpPort;
    self.smtpSession.port = (unsigned int)_smtpPort;
}

- (void)setSmtpAuthType:(NSInteger)smtpAuthType{
    _smtpAuthType = smtpAuthType;
    self.smtpSession.authType = smtpAuthType;
}


#pragma mark - IMAP
#pragma mark account
/**
 Verify the mail account(Login) 邮箱验证（登陆）

 @param success 成功回调
 @param failure 失败回调
 */
- (void)checkAccountSuccess:(void (^)())success failure:(void (^)(NSError *  error))failure{
    MCOIMAPOperation *operation = [self.imapSession checkAccountOperation];
    [operation start:^(NSError * _Nullable error) {
        if (error){
            NSLog(@"Fail to verify =====> %@",error);
            if(failure){
                failure(error);
            }
        }else{
            NSLog(@"Pass verification");
            if (success) {
                success();
            }
        }
    }];
}

#pragma mark folder
/**
 Get all folders of mail account 获取邮箱目录

 @param success 成功回调
 @param failure 失败回调
 */
- (void)fetchAllFoldersSuccess:(void (^)(NSArray<CYFolder *> *folders))success failure:(void (^)(NSError *  error))failure{
    
    __weak typeof(self) weakSelf = self;
    MCOIMAPFetchFoldersOperation *operation = [self.imapSession fetchAllFoldersOperation];
    [operation start:^(NSError * _Nullable error, NSArray * _Nullable folders) {
        if (error){
            NSLog(@"Fail to get folder list =====> %@",error);
            if(failure){
                failure(error);
            }
        }else{
            NSLog(@"Success to get folder list");
            NSMutableArray *array = [NSMutableArray array];
            for (MCOIMAPFolder *folder in folders) {
                CYFolder *cyfolder = (CYFolder *)[[CYMailModelManager sharedCYMailModelManager]createManagedObjectOfClass:CYFolder.self];
                cyfolder.path = folder.path;
                cyfolder.name = [[weakSelf.imapSession defaultNamespace] componentsFromPath:folder.path][0];
                cyfolder.flags = [[NSNumber alloc]initWithInteger:folder.flags];
                [array addObject:cyfolder];
            }
            if (success) {
                success(array);
            }
        }
    }];
}

/**
 Query folder status(like unseen) 获取目录信息(未读数)

 @param folder 目录path
 @param success 成功回调
 @param failure 失败回调
 */
- (void)folderStatusOfFolder:(NSString *)folder success:(void (^)(MCOIMAPFolderStatus *status))success failure:(void (^)(NSError *  error))failure{
    
    MCOIMAPFolderStatusOperation *folderStatus = [self.imapSession folderStatusOperation:folder];
    [folderStatus start:^(NSError * _Nullable error, MCOIMAPFolderStatus * _Nullable status) {
        if (error){
            NSLog(@"Fail to get %@ status =====> %@",folder,error);
            if(failure){
                failure(error);
            }
        }else{
            NSLog(@"Success to get %@ status",folder);
            if (success) {
                success(status);
            }
        }
    }];
}

#pragma mark mail
/**
 Get mail list by uid range 以uid范围获取邮件

 @param folderPath 目录路径
 @param startUid 起始邮件Uid
 @param length uid跨度
 @param success 成功回调
 @param failure 失败回调
 */
- (void)fetchMailsOfFolder:(CYFolder *)folder startUid:(NSUInteger)startUid length:(NSUInteger)length success:(void (^)(NSArray<CYMail *> *mails))success failure:(void (^)(NSError *error))failure{
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    
    (MCOIMAPMessagesRequestKindStructure |MCOIMAPMessagesRequestKindInternalDate |MCOIMAPMessagesRequestKindHeaderSubject |MCOIMAPMessagesRequestKindFlags |MCOIMAPMessagesRequestKindFullHeaders);
    
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(3000,length)];
    
    MCOIMAPFetchMessagesOperation *fetchOperation = [self.imapSession fetchMessagesOperationWithFolder:folder.path requestKind:requestKind uids:uids];
    
    [fetchOperation start:^(NSError *error,NSArray * fetchedMessages,MCOIndexSet * vanishedMessages) {
        if(error){
            NSLog(@"Fail to get mail list =====> %@", error);
            if (failure) {
                failure(error);
            }
        }else{
            NSLog(@"Success to get mail list");
            if (success) {
                NSMutableArray<CYMail *> *mails = [NSMutableArray array];
                [fetchedMessages enumerateObjectsUsingBlock:^(MCOIMAPMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CYMail *mail = [[CYMailModelManager sharedCYMailModelManager]createMailWithMessage:obj folder:folder];
                    [mails addObject:mail];
                    
                    if ([mail.uid integerValue]>=[folder.nextUid integerValue]) {
                        folder.nextUid = @([mail.uid integerValue]+1);
                    }
                    
                    if ([mail.uid integerValue]<[folder.firstUid integerValue]) {
                        folder.firstUid = @([mail.uid integerValue]);
                    }
                    
                }];
                
                [[CYMailModelManager sharedCYMailModelManager]save:&error];
                
                if(error){
                    NSLog(@"Fail to cache mail list =====> %@", error);
                    [[CYMailModelManager sharedCYMailModelManager]rollback];
                    if (failure) {
                        failure(error);
                    }
                }else{
                    success([mails copy]);
                }
            }
        }
    }];
    
}

/**
 Sync and update the mails status 同步更新邮件状态

 @param folder 邮件目录
 @param success 成功回调
 @param failure 失败回调
 */
- (void)syncMailWith:(CYFolder *)folder success:(void (^)())success failure:(void (^)(NSError *error))failure{
    
    MCOIMAPFolderInfoOperation *infoOperation = [self.imapSession folderInfoOperation:folder.path];
    [infoOperation start:^(NSError * _Nullable error, MCOIMAPFolderInfo * _Nullable info) {
        if(error){
            NSLog(@"Fail to get modSequenceValue =====> %@", error);
            if (failure) {
                failure(error);
            }
        }
        if (info.modSequenceValue == 0) return;
        
        MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake([folder.firstUid integerValue],UINT64_MAX)];
        
        MCOIMAPFetchMessagesOperation *messageOpration = [self.imapSession syncMessagesWithFolder:folder.path requestKind:MCOIMAPMessagesRequestKindUid uids:uids modSeq:info.modSequenceValue];
        [messageOpration start:^(NSError * _Nullable error, NSArray * _Nullable messages, MCOIndexSet * _Nullable vanishedMessages) {
            if(error){
                NSLog(@"Fail to sync the mails =====> %@", error);
                if (failure) {
                    failure(error);
                }
            }else{
                NSLog(@"Success to sync the mails");
                [[CYMailModelManager sharedCYMailModelManager]syncMailWithMessage:messages folder:folder];
                if (success) {
                    success();
                }
            }
        }];
        
    }];
}

/**
 Get mail content in html  获取邮件HTML正文

 @param mail 邮件对象
 @param success 成功回调
 @param failure 失败回调
 */
- (void)fetchHtmlBodyWithMail:(CYMail *)mail success:(void (^)(NSString *htmlBody))success failure:(void (^)(NSError *  error))failure{
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)(MCOIMAPMessagesRequestKindStructure);
    
    MCOIndexSet *uid = [MCOIndexSet indexSetWithIndex:[mail.uid integerValue]];
    
    MCOIMAPFetchMessagesOperation *fetchOperation = [self.imapSession fetchMessagesOperationWithFolder:mail.folderPath requestKind:requestKind uids:uid];
    
    [fetchOperation start:^(NSError *error,NSArray * fetchedMessages,MCOIndexSet * vanishedMessages) {
        if(error||!fetchedMessages||fetchedMessages.count<=0){
            NSLog(@"Fail to get mail's content =====> %@", error);
            if (failure) {
                failure(error);
            }
        }else{
            MCOIMAPMessageRenderingOperation *operation = [self.imapSession htmlBodyRenderingOperationWithMessage:fetchedMessages[0] folder:mail.folderPath];
            [operation start:^(NSString * htmlString, NSError * error) {
                if(error){
                    NSLog(@"Fail to get mail's content =====> %@", error);
                    failure(error);
                }else{
                    NSLog(@"Success to get mail's content ====> %@ ",htmlString);
                    if ([NSString isBlankString:htmlString]) {
                        htmlString = @"-";
                    }
                    mail.content = htmlString;
                    [[CYMailModelManager sharedCYMailModelManager]save:nil];
                    success(htmlString);
                }
            }];
        }
    }];
}

/**
 Download attachment 下载附件

 @param attachment 附件
 @param downloadPath 本地路径
 @param success 成功回调
 @param failure 失败回调
 @param progress 进度回调
 */
- (void)downloadAttachment:(CYAttachment *)attachment downloadPath:(NSString *)downloadPath success:(void (^)())success failure:(void (^)(NSError *  error))failure progress:(void (^)(NSInteger current, NSInteger maximum))progress{
    
    MCOIMAPFetchContentOperation * op = [self.imapSession fetchMessageAttachmentOperationWithFolder:attachment.folderPath uid:[attachment.uid unsignedIntValue] partID:attachment.partid encoding:MCOEncodingBase64];
    [op start:^(NSError * error, NSData * partData) {
        
        if (error) {
            NSLog(@"Fail to download ==> %@", error);
            if (failure) {
                failure(error);
            }
        }
        
        if ([partData writeToFile:downloadPath atomically:YES]) {
            NSLog(@"Save attachment to ==> %@",downloadPath);
            if (success) {
                success();
            }
        }else{
            NSLog(@"Fail to sava attachment");
            if (failure) {
                failure(nil);
            }
        }
    }];
    op.progress = ^(unsigned int current, unsigned int maximum){
        if (progress) {
            progress(current,maximum);
        }
    };
}

/**
 Delete Mail. if the mail is in trash box, delete directly. if not, move to trash box 删除邮件,如果邮件已经在”已删除“，直接删除，否则移动至“已删除”

 @param mail 邮件
 @param success 成功回调
 @param failure 失败回调
 */
- (void)deleteMail:(CYMail *)mail inFolder:(CYFolder *)folder success:(void (^)())success failure:(void (^)(NSError *  error))failure{
    
    if ([CYMailUtil isTrashFolder:folder]) {//in trash folder
        [self deleteMailDirectlyWithUid:[mail.uid unsignedIntegerValue] folerPath:mail.folderPath success:^{
            if(success){
                success();
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }else{//not in trash folder
        CYFolder *trashFolder = [[CYMailModelManager sharedCYMailModelManager]trashFolderOfAccount:folder.account.username error:nil];
        [self moveMail:mail destFolder:trashFolder.path success:^{
            if(success){
                success();
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }
}

/**
 Delete Mail Directly 直接删除邮件

 @param uid uid
 @param folderPath 目录路径
 @param success 成功回调
 @param failure 失败回调
 */
- (void)deleteMailDirectlyWithUid:(NSUInteger)uid folerPath:(NSString *)folderPath success:(void (^)())success failure:(void (^)(NSError *))failure{
    
    MCOIMAPOperation *operation = [self.imapSession storeFlagsOperationWithFolder:folderPath uids:[MCOIndexSet indexSetWithIndex:uid] kind:MCOIMAPStoreFlagsRequestKindSet flags:MCOMessageFlagDeleted];
    [operation start:^(NSError * error) {
        
        if (error){
            NSLog(@"Fail to delete mail =====> %@", error);
            if (failure) {
                failure(error);
            }
            return;
        }
        
        MCOIMAPOperation *deleteOp = [self.imapSession expungeOperation:folderPath];
        [deleteOp start:^(NSError *error) {
            if(error){
                NSLog(@"Fail to delete mail =====> %@", error);
                if (failure) {
                    failure(error);
                }
            }else{
                NSLog(@"Success to delete mail");
                if(success){
                    success();
                }
            }
        }];
    }];
}

/**
 Move mail to other folder 邮件移动

 @param mail 邮件
 @param destFolder 目标目录
 @param success 成功回调
 @param failure 失败回调
 */
- (void)moveMail:(CYMail *)mail destFolder:(NSString *)destFolder success:(void (^)())success failure:(void (^)(NSError *  error))failure{
    
    NSUInteger uid = [mail.uid unsignedIntegerValue];
    NSString *folderPath = mail.folderPath;
    
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(uid,1)];
    MCOIMAPCopyMessagesOperation *operation = [self.imapSession copyMessagesOperationWithFolder:mail.folderPath uids:uids destFolder:destFolder];
    [operation start:^(NSError * _Nullable error, NSDictionary * _Nullable uidMapping) {
        if (error){
            NSLog(@"Fail to move mail =====> %@", error);
            if (failure) {
                failure(error);
            }
            return;
        }
        NSLog(@"Success to move mail");
        if(success){
            success();
        }
        [self deleteMailDirectlyWithUid:uid folerPath:folderPath success:nil failure:nil];
    }];
}

/**
 Update mail status to seen 标记邮件为已读

 @param mail 邮件
 @param success 成功回调
 @param failure 失败回调
 */
- (void)updateMailAsSeen:(CYMail *)mail success:(void (^)())success failure:(void (^)(NSError *  error))failure{
    mail.flags = @([mail.flags integerValue]|MCOMessageFlagSeen);
    [[CYMailModelManager sharedCYMailModelManager]save:nil];
    MCOIMAPOperation *operation = [self.imapSession storeFlagsOperationWithFolder:mail.folderPath uids:[MCOIndexSet indexSetWithIndex:[mail.uid integerValue]] kind:MCOIMAPStoreFlagsRequestKindSet flags:MCOMessageFlagSeen];
    [operation start:^(NSError * error) {
        if(error){
            NSLog(@"Fail to update status =====> %@", error);
            if(failure){
                failure(error);
            }
        }else{
            NSLog(@"Success to update status");
            if (success) {
                success();
            }
        }
    }];
}

#pragma mark SMTP
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
- (void)sendMailWithSubject:(NSString *)subject content:(NSString *)content toArray:(NSArray *)toArray ccArray:(NSArray *)ccArray bccArray:(NSArray *)bccArray attachmentArray:(NSArray<CYTempAttachment *> *)attachments originMail:(CYMail *)originMail success:(void (^)())success failure:(void (^)(NSError *  error))failure progress:(void (^)(NSInteger current, NSInteger maximum))progress{
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    
    //From
    NSString *nickname = self.nickname;
    if ([NSString isBlankString:nickname]) {
        nickname = self.username;
    }
    MCOAddress *fromAdd = [MCOAddress addressWithDisplayName:nickname mailbox:self.username];
    [[builder header] setFrom:fromAdd];
    
    //To
    NSMutableArray *mutableListTo = [NSMutableArray array];
    for (NSString *to in toArray) {
        MCOAddress *toAdd = [MCOAddress addressWithDisplayName:to mailbox:to];
        [mutableListTo addObject:toAdd];
    }
    [[builder header] setTo:mutableListTo];
    
    //Cc
    NSMutableArray *mutableListCc = [NSMutableArray array];
    for (NSString *cc in ccArray) {
        MCOAddress *ccAdd = [MCOAddress addressWithDisplayName:cc mailbox:cc];
        [mutableListCc addObject:ccAdd];
    }
    [[builder header] setCc:mutableListCc];
    
    //Bcc
    NSMutableArray *mutableListBcc = [NSMutableArray array];
    for (NSString *bcc in bccArray) {
        MCOAddress *bccAdd = [MCOAddress addressWithDisplayName:bcc mailbox:bcc];
        [mutableListBcc addObject:bccAdd];
    }
    [[builder header] setBcc:mutableListBcc];
    
    //Subject
    [[builder header] setSubject:[NSString stringWithCString:[subject UTF8String] encoding:NSUTF8StringEncoding]];
    
    //Content
    [builder setHTMLBody:[content stringByReplacingOccurrencesOfString:@"\n"withString:@"<br/>"]];
    
    //Attachment
    NSMutableArray *mocattachmentList = [[NSMutableArray alloc]init];
    for (CYTempAttachment *attachment in attachments) {
        MCOAttachment *mocattachment = [MCOAttachment attachmentWithData:attachment.fileData filename:attachment.fileName];
        [mocattachmentList addObject:mocattachment];
    }
    
    //Sent folder
    CYFolder *sentFolder = [[CYMailModelManager sharedCYMailModelManager]sentFolderOfAccount:self.username error:nil];
    
    void (^sendBlock)(NSData *) = ^(NSData *data){
        MCOSMTPSendOperation *sendOperation = [self.smtpSession sendOperationWithData:data];
        [sendOperation start:^(NSError *error) {
            if(error) {
                NSLog(@"Fail to send mail=====》%@",error);
                failure(error);
            } else {
                NSLog(@"Success to send mail");
                //make a copy to sent folder
                if (![NSString isBlankString:sentFolder.path]) {
                    MCOIMAPAppendMessageOperation *op = [self.imapSession appendMessageOperationWithFolder:sentFolder.path messageData:data flags:MCOMessageFlagNone];
                    [op start:^(NSError *error, uint32_t createdUID) {}];
                }
                success();
            }
        }];
        sendOperation.progress =^(unsigned int current, unsigned int maximum){
            progress(current,maximum);
        };
    };
    
    if (originMail&&originMail.attachments.count>0) {
        MCOIMAPFetchContentOperation *fetchContentOp = [self.imapSession fetchMessageOperationWithFolder:originMail.folderPath uid:[originMail.uid unsignedIntValue]];
        [fetchContentOp start:^(NSError * error, NSData * data) {
            
            if (error) {
                NSLog(@"Fail to forward mail=====》%@",error);
                failure(error);
                return;
            }
            
            MCOMessageParser *msgPareser = [MCOMessageParser messageParserWithData:data];
            for (MCOAttachment *attachment in msgPareser.attachments) {
                [mocattachmentList addObject:attachment];
            }
            
            builder.attachments = mocattachmentList;
            NSData *mailData = [builder data];
            
            sendBlock(mailData);
        }];
    }else{
        builder.attachments = mocattachmentList;
        NSData *mailData = [builder data];
        
        sendBlock(mailData);
    }
}

@end
