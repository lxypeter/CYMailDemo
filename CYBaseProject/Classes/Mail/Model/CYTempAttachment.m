//
//  CYTempAttachment.m
//  CYMailDemo
//
//  Created by Peter Lee on 2017/1/30.
//  Copyright © 2017年 CY.Lee. All rights reserved.
//

#import "CYTempAttachment.h"

@implementation CYTempAttachment

+ (CYTempAttachment *)attachmentModelWithFileName:(NSString *)fileName fileData:(NSData *)fileData{
    CYTempAttachment *attachment = [[CYTempAttachment alloc]initWithFileName:fileName fileData:fileData];
    return attachment;
}

- (CYTempAttachment *)initWithFileName:(NSString *)fileName fileData:(NSData *)fileData{
    self = [super init];
    if (self) {
        _fileName = [fileName copy];
        _fileData = fileData;
    }
    return self;
}

@end
