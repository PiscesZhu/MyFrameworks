//
//  AsyncZipArchive.h
//  AsyncZipArchive
//
//  Created by zhi.zhu on 12-4-24.
//  Copyright (c) 2012年 Yek. All rights reserved.
//

/*
    基于ZipArchive的异步压缩和解压缩工具
 */
#import <Foundation/Foundation.h>

#import "ZipArchive.h"

@protocol AsyncZipArchiveDelegate <NSObject>
@optional
// 开始解压
-(void)unzipStarted:(NSString *)file;
// 解压缩失败
-(void)unzipFailed:(NSString *)file errorMessage:(NSString*) msg;
// 单个文件解压缩完成
-(void)unzipSuccessed:(NSString *)file;
// 是否覆盖文件
-(BOOL)OverWriteOperation:(NSString*)file;

// 开始压缩
-(void)compressStarted:(NSArray *)fileArray;
// 压缩失败
-(void)compressFailed:(NSArray *)fileArray errorMessage:(NSString*) msg;
// 压缩完成
-(void)compressSuccessed:(NSArray *)fileArray;

@end

@interface AsyncZipArchive : NSObject<ZipArchiveDelegate>{
    NSOperationQueue *unzipQueue;
    NSOperationQueue *zipQueue;
    id<AsyncZipArchiveDelegate> _delegate;
}
// count:最多的并发数
- (id)initWithArchiveDelegate:(id)delegate maxConcurrentOperationCount:(NSInteger)count;
// 解压缩aZipFile到aPath
- (BOOL)unzipFile:(NSString *)aZipFile password:(NSString *)aPassword to:(NSString *)aPath overWrite:(BOOL)isOverWrite;
// 压缩aFilesArray到aFile
- (BOOL)zipFiles:(NSArray *)aFilesArray password:(NSString *)aPassword to:(NSString *)aFile;
@end

@interface UnzipOperation : NSOperation {
    NSString *_zipFile; // 需要解压的压缩包名称
    NSString *_password;// 压缩文件密码,如果不需要密码则设置为nil
    NSString *_toPath;  // 解压到的路径
    BOOL _overWrite;    // 是否覆盖已经存在的文件,如果该值为NO,则会每次询问delegate,是否覆盖
    id<AsyncZipArchiveDelegate> _delegate;
}
@property (retain) NSString *zipFile;
@property (retain) NSString *password;
@property (retain) NSString *toPath;
@property (assign) BOOL isOverWrite;
@property (assign) id<AsyncZipArchiveDelegate> delegate;

- (id)initWithZipFile:(NSString *)aZipFile password:(NSString *)aPassword to:(NSString *)aPath overWrite:(BOOL)isOverWrite;
@end

@interface ZipOperation : NSOperation {
    NSArray *_filesArray; // 需要压缩的文件和文件夹列表
    NSString *_password;  // 压缩文件密码,如果不需要密码则设置为nil
    NSString *_toFile;    // 生成压缩包的文件名 xx.zip
    id<AsyncZipArchiveDelegate> _delegate;
}
@property (retain) NSArray *filesArray;
@property (retain) NSString *password;
@property (retain) NSString *toFile;
@property (assign) id<AsyncZipArchiveDelegate> delegate;

- (id)initWithFiles:(NSArray *)aFilesArray password:(NSString *)aPassword to:(NSString *)aFile;
@end