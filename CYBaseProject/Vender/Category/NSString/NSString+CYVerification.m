//
//  NSString+Category
//  gs_1210
//
//  Created by musoon on 15/1/2.
//  Copyright (c) 2015年 areo. All rights reserved.
//

#import "NSString+CYVerification.h"

@implementation NSString (CYVerification)

+ (BOOL)isBlankString:(NSString *)string{
    
    if (string == nil || string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
