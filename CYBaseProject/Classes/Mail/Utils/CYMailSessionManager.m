//
//  MailSessionManager.m
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/12.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import "CYMailSessionManager.h"
#import "CYMailSession.h"
#import "CYMailAccount.h"

@interface CYMailSessionManager ()

@property (nonatomic, strong) NSMutableDictionary *sessions;

@end

@implementation CYMailSessionManager

SingletonM(CYMailSessionManager)

- (NSMutableDictionary *)sessions{
    if (!_sessions) {
        _sessions = [NSMutableDictionary dictionary];
    }
    return _sessions;
}

- (CYMailSession *)registerSessionWithAccount:(CYMailAccount *)account{
    
    CYMailSession *session = [[CYMailSession alloc]init];
    session.username = account.username;
    session.password = account.password;
    session.password = account.password;
    session.imapHostname = account.fetchHost;
    session.imapPort = [account.fetchPort unsignedIntegerValue];
    session.smtpHostname = account.sendHost;
    session.smtpPort = [account.sendPort unsignedIntegerValue];
    session.nickname = account.nickName;
    session.smtpAuthType = [account.smtpAuthType integerValue];
    if (account.ssl) {
        session.imapConnectionType = CYMailConnectionTypeTLS;
    }else{
        session.imapConnectionType = CYMailConnectionTypeClear;
    }
    
    [self.sessions setObject:session forKey:account.username];
    
    return session;
}

- (CYMailSession *)getSessionWithUsername:(NSString *)username{
    return self.sessions[username];
}

- (void)deregisterSessionWithUsername:(NSString *)username{
    if (![NSString isBlankString:username]) {
        [self.sessions removeObjectForKey:username];
    }
}

@end
