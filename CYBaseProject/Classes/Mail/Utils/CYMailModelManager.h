//
//  CYMailModelManager.h
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/12.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYMailAccount.h"
#import "CYMail.h"
#import "CYFolder.h"
#import "CYAttachment.h"
#import "Singleton.h"

@class NSManagedObjectContext,MCOIMAPMessage,CYMailAccount;

@interface CYMailModelManager : NSObject

SingletonH(CYMailModelManager)

@property (nonatomic, strong, readonly) NSManagedObjectContext *context;

- (NSManagedObject *)createManagedObjectOfClass:(Class)clazz;
- (BOOL)save:(NSError **)error;
- (void)rollback;

@end

//CYMailAccount
@interface CYMailModelManager (MailAccount)

/**
 Query all mail accounts 所有邮件账户
 
 @param error 异常
 @return all mail accounts 所有邮件账户
 */
- (NSArray<CYMailAccount *> *)allAccount:(NSError **)error;

/**
 Delete mail account 删除账户

 @param mailAccount 账户
 @param error 异常
 */
- (BOOL)deleteMailAccount:(CYMailAccount *)mailAccount error:(NSError **)error;

@end

//CYMail
@interface CYMailModelManager (Mail)

/**
 Query all mails of account 账户下所有邮件

 @param mailAccount 邮件账户
 @param error 异常
 @return all mails of account 账户下所有邮件
 */
- (NSArray<CYMail *> *)allMailsOfAccount:(NSString *)account error:(NSError **)error;

/**
 Query all mails of folder 目录下所有邮件

 @param folder 邮件目录
 @param error 异常
 @return all mails of folder 目录下所有邮件
 */
- (NSArray<CYMail *> *)mailsOfFolder:(CYFolder *)folder error:(NSError **)error;


/**
 Create a empty mail model 生成邮件

 @param message 接口返回信息
 @param folder 邮件目录
 @return empty mail model 邮件
 */
- (CYMail *)createMailWithMessage:(MCOIMAPMessage *)message folder:(CYFolder *)folder;


/**
 Sync mails' flags 同步更新缓存邮件

 @param messages 接口返回信息
 @param folder 邮件目录
 */
- (void)syncMailWithMessage:(NSArray<MCOIMAPMessage *> *)messages folder:(CYFolder *)folder;

/**
 Delete mail 删除邮件

 @param mail 邮件
 @param error 异常
 */
- (BOOL)deleteMail:(CYMail *)mail error:(NSError **)error;

/**
 Delete all mails of account 删除账户下所有邮件

 @param mailAccount 邮件账户
 */
- (BOOL)deleteAllMailOfAccount:(NSString *)account;

@end

//CYFolder
@interface CYMailModelManager (Folder)

/**
 Get trash folder 获取"已删除"文件夹

 @param account 邮件账户
 @param error 异常
 */
- (CYFolder *)trashFolderOfAccount:(NSString *)account error:(NSError **)error;

/**
 Get sent folder 获取"已发送"文件夹
 
 @param account 邮件账户
 @param error 异常
 */
- (CYFolder *)sentFolderOfAccount:(NSString *)account error:(NSError **)error;

@end

