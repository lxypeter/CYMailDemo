//
//  CYMailModelManager.m
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/12.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import "CYMailModelManager.h"
#import <MailCore/MailCore.h>
#import <CoreData/CoreData.h>
#import "CYMailUtil.h"

@interface CYMailModelManager ()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation CYMailModelManager

SingletonM(CYMailModelManager)

- (NSManagedObjectContext *)context{
    
    if (!_context) {
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSError *error = nil;
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *sqlitePath = [doc stringByAppendingFormat:@"/CYMailModel.slqite"];
        NSLog(@"path =====> %@",sqlitePath);
        
        [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlitePath] options:nil error:&error];
        
        _context.persistentStoreCoordinator = store;
    }
    
    return _context;
}

- (NSManagedObject *)createManagedObjectOfClass:(Class)clazz{
    if(![clazz isSubclassOfClass:NSManagedObject.self]){
        return nil;
    }
    
    NSString *className = NSStringFromClass(clazz);
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:self.context];
    
    return object;
}

- (BOOL)save:(NSError **)error{
    if ([self.context hasChanges]) {
        return [self.context save:error];
    }
    return YES;
}

- (void)rollback{
    [self.context rollback];
}

@end


@implementation CYMailModelManager(User)

- (NSArray<CYMailAccount *> *)allAccount:(NSError **)error{
    NSFetchRequest *request = [CYMailAccount fetchRequest];
    NSArray *mailAccounts = [self.context executeFetchRequest:request error:error];
    
    if(!mailAccounts) return @[];
    
    return mailAccounts;
}

- (BOOL)deleteMailAccount:(CYMailAccount *)mailAccount error:(NSError **)error{
    NSString *account = mailAccount.username;
    [self.context deleteObject:mailAccount];
    BOOL result = [self.context save:error];
    if (result) {
        [self deleteAllMailOfAccount:account];
    }
    return result;
}

@end

@implementation CYMailModelManager(Mail)

- (NSArray<CYMail *> *)allMailsOfAccount:(NSString *)account error:(NSError **)error{
    NSFetchRequest *mailRequest = [CYMail fetchRequest];
    NSPredicate *mailPre = [NSPredicate predicateWithFormat:@"account=%@",account];
    mailRequest.predicate = mailPre;
    NSArray<CYMail *> *mails = [self.context executeFetchRequest:mailRequest error:error];
    if(!mails) return @[];
    
    return mails;
}

- (NSArray<CYMail *> *)mailsOfFolder:(CYFolder *)folder error:(NSError **)error{
    
    NSFetchRequest *mailRequest = [CYMail fetchRequest];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"account=%@ AND folderPath=%@",folder.account.username,folder.path];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"receivedDate" ascending:NO];
    
    mailRequest.predicate = pre;
    mailRequest.sortDescriptors = [NSArray arrayWithObject:sort];
    
    NSArray<CYMail *> *mails = [self.context executeFetchRequest:mailRequest error:error];
    
    if(!mails) return @[];
    
    return mails;
}

- (CYMail *)createMailWithMessage:(MCOIMAPMessage *)message folder:(CYFolder *)folder{
    
    CYMail *mail = (CYMail *)[self createManagedObjectOfClass:CYMail.self];
    
    mail.account = folder.account.username;
    mail.folderPath = folder.path;
    mail.uid = @(message.uid);
    mail.subject = message.header.subject;
    mail.fromName = message.header.from.displayName;
    mail.fromAddress = message.header.from.mailbox;
    mail.sendDate = message.header.date;
    mail.receivedDate = message.header.receivedDate;
    mail.flags = @(message.flags);
    NSMutableString *cc = [NSMutableString string];
    NSString *dot = @"";
    for (MCOAddress *address in message.header.cc) {
        [cc appendString:dot];
        [cc appendString:address.mailbox];
        dot = @";";
    }
    mail.cc = cc;
    NSMutableString *bcc = [NSMutableString string];
    dot = @"";
    for (MCOAddress *address in message.header.bcc) {
        [bcc appendString:dot];
        [bcc appendString:address.mailbox];
        dot = @";";
    }
    mail.bcc = bcc;
    dot = @"";
    NSMutableString *to = [NSMutableString string];
    for (MCOAddress *address in message.header.to) {
        [to appendString:dot];
        [to appendString:address.mailbox];
        dot = @";";
    }
    mail.to = to;
    NSArray *attachments = message.attachments;
    mail.attachmentCount = @(attachments.count);
    for (MCOIMAPPart *attachment in attachments) {
        CYAttachment *mailAttachment = (CYAttachment *)[self createManagedObjectOfClass:CYAttachment.self];
        mailAttachment.uid = mail.uid;
        mailAttachment.folderPath = mail.folderPath;
        mailAttachment.partid = attachment.partID;
        mailAttachment.filename = attachment.filename;
        [mail addAttachmentsObject:mailAttachment];
    }
    
    return mail;
}

- (void)syncMailWithMessage:(NSArray<MCOIMAPMessage *> *)messages folder:(CYFolder *)folder{
    NSError *error = nil;
    NSArray *mails = [self mailsOfFolder:folder error:&error];
    if (error) return;
    
    NSMutableDictionary *messDict = [NSMutableDictionary dictionary];
    for (MCOIMAPMessage *message in messages) {
        [messDict setObject:message forKey:[NSString stringWithFormat:@"%@",@(message.uid)]];
    }
    
    [mails enumerateObjectsUsingBlock:^(CYMail *  _Nonnull mail, NSUInteger idx, BOOL * _Nonnull stop) {
        MCOIMAPMessage *message = messDict[[NSString stringWithFormat:@"%@",mail.uid]];
        if (message) {
            mail.flags = @(message.flags);
        }else{
            if ([mail.uid integerValue]<[folder.nextUid integerValue]) {
                [self deleteMail:mail error:nil];
            }
        }
    }];
    
    [self save:nil];
    
}

- (BOOL)deleteMail:(CYMail *)mail error:(NSError **)error{
    [self.context deleteObject:mail];
    return [self.context save:error];
}

- (BOOL)deleteAllMailOfAccount:(NSString *)account{
    NSArray *mails = [self allMailsOfAccount:account error:nil];
    NSError *error = nil;
    
    for (CYMail *mail in mails) {
        [self deleteMail:mail error:&error];
        
        if (error) {
            [self.context rollback];
            return NO;
        }
    }
    return YES;
}
@end

//CYFolder
@implementation CYMailModelManager(Folder)

- (CYFolder *)trashFolderOfAccount:(NSString *)account error:(NSError **)error{
    
    NSFetchRequest *request = [CYFolder fetchRequest];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"account.username=%@",account];
    request.predicate = pre;
    
    NSArray *mailFolders = [self.context executeFetchRequest:request error:error];
    if (mailFolders&&mailFolders.count>0) {
        for (CYFolder *folder in mailFolders) {
            if ([CYMailUtil isTrashFolder:folder]) {
                return folder;
            }
        }
    }
    return nil;
}

- (CYFolder *)sentFolderOfAccount:(NSString *)account error:(NSError **)error{
    
    NSFetchRequest *request = [CYFolder fetchRequest];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"account.username=%@",account];
    request.predicate = pre;
    
    NSArray *mailFolders = [self.context executeFetchRequest:request error:error];
    if (mailFolders&&mailFolders.count>0) {
        for (CYFolder *folder in mailFolders) {
            if ([CYMailUtil isSentFolder:folder]) {
                return folder;
            }
        }
    }
    return nil;
}

@end
