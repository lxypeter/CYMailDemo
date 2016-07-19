//
//  AppDelegate.m
//  ZTESoftProject
//
//  Created by YYang on 16/2/6.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "AppDelegate.h"
#import "IQKeyboardManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //1.设置 log 信息
    [self setLogger];
    
    [IQKeyboardManager sharedManager].enable = YES;
    
    DDLogError(@"Paper jam");
    DDLogWarn(@"Toner is low");
    DDLogInfo(@"Warming up printer (pre-customization)");
    DDLogVerbose(@"Intializing protcol x26 (pre-customization)");
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/**
 *  @author YYang, 16-02-08 16:02:10
 *
 *  日志操作
 */
- (void)setLogger{
    //设置打印级别
    [DDLog addLogger:[DDTTYLogger sharedInstance]withLevel:ddLogLevel];
    //彩色打印
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    //自定义颜色
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor purpleColor] backgroundColor:[UIColor whiteColor] forFlag:DDLogFlagInfo];
}


@end
