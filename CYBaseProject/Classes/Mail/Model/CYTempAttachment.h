//
//  CYTempAttachment.h
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/30.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYTempAttachment : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) NSData *fileData;
+ (CYTempAttachment *)attachmentModelWithFileName:(NSString *)fileName fileData:(NSData *)fileData;
- (CYTempAttachment *)initWithFileName:(NSString *)fileName fileData:(NSData *)fileData;

@end
