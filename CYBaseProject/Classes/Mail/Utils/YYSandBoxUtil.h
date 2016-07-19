//
//  YYSandBoxUtil.h
//  GXMoblieOA
//
//  Created by YYang on 16/3/28.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYSandBoxUtil : NSObject

/**
 *  @author YYang, 16-03-28 16:03:01
 *
 *  获取沙盒Document的文件目录
 *
 *  @return 路径
 */
+ (NSString *)getDocumentDirectory;

/**
 *  @author YYang, 16-03-28 16:03:21
 *
 *  获取沙盒Library的文件目录
 *
 *  @return 路径
 */
+ (NSString *)getLibraryDirectory;

/**
 *  @author YYang, 16-03-28 16:03:35
 *
 *  获取沙盒Library/Caches的文件目录
 *
 *  @return 路径
 */
+ (NSString *)getCachesDirectory;

/**
 *  @author YYang, 16-03-28 16:03:43
 *
 *  获取沙盒Preference的文件目录
 *
 *  @return 路径
 */
+ (NSString *)getPreferencePanesDirectory;

/**
 *  @author YYang, 16-03-28 16:03:56
 *
 *  获取沙盒tmp的文件目录
 *
 *  @return 路径
 */
+ (NSString *)getTmpDirectory;


/**
 *  @author YYang, 16-03-28 16:03:05
 *
 *  根据路径返回目录或文件的大小
 *
 *  @param path 指定路径
 *
 *  @return 文件大小
 */
+ (double)sizeWithFilePath:(NSString *)path;

/**
 *  @author YYang, 16-03-28 16:03:30
 *
 *   得到指定目录下的所有文件
 *
 *  @param dirPath 指定路径
 *
 *  @return 文件
 */
+ (NSArray *)getAllFileNames:(NSString *)dirPath;

/**
 *  @author YYang, 16-03-28 16:03:43
 *
 *  删除指定目录或文件
 *
 *  @param path 指定路径
 *
 *  @return 成功?
 */
+ (BOOL)clearCachesWithFilePath:(NSString *)path;

/**
 *  @author YYang, 16-03-28 16:03:13
 *
 *   清空指定目录下文件
 *
 *  @param dirPath 指定路径
 *
 *  @return 成功?
 */
+ (BOOL)clearCachesFromDirectoryPath:(NSString *)dirPath;

/**
 *  @author Mon
 *
 *  @brief Detect whether a directory exists, if exists, return YES, if not, create one and return NO
 *
 *  @param folderPath The directory's absolute path to detect
 *
 *  @return whether the directory is created when being detected
 */
+ (BOOL)createIfNotExistsFolder:(NSString *)folderPath;
@end
