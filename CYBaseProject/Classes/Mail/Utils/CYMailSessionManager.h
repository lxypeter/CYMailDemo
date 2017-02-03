//
//  MailSessionManager.h
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/12.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "CYMailSession.h"

@class CYMailAccount;
@interface CYMailSessionManager : NSObject

SingletonH(CYMailSessionManager)

- (CYMailSession *)registerSessionWithAccount:(CYMailAccount *)account;
- (CYMailSession *)getSessionWithUsername:(NSString *)username;
- (void)deregisterSessionWithUsername:(NSString *)username;

@end
