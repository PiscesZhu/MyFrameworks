//
//  AsyncZipArchive.m
//  AsyncZipArchive
//
//  Created by zhi.zhu on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AsyncZipArchive.h"

@implementation AsyncZipArchive

- (id)initWithArchiveDelegate:(id)delegate maxConcurrentOperationCount:(NSInteger)count{
    self = [super init];
    if (self) {
        unzipQueue = [[NSOperationQueue alloc] init];
        [unzipQueue setMaxConcurrentOperationCount:count];
        zipQueue = [[NSOperationQueue alloc] init];
        [zipQueue setMaxConcurrentOperationCount:count];
        _delegate = delegate;
    }
    return self;
}

- (BOOL)unzipFile:(NSString *)aZipFile password:(NSString *)aPassword to:(NSString *)aPath overWrite:(BOOL)isOverWrite{
    
    UnzipOperation *oper = [[UnzipOperation alloc] initWithZipFile:aZipFile password:aPath to:aPath overWrite:isOverWrite];
    oper.delegate = _delegate;
    [unzipQueue addOperation:oper];
    [oper release];
    return YES;
}

- (BOOL)zipFiles:(NSArray *)aFilesArray password:(NSString *)aPassword to:(NSString *)aFile{
    
    ZipOperation *oper = [[ZipOperation alloc] initWithFiles:aFilesArray password:aPassword to:aFile];
    oper.delegate = _delegate;
    [zipQueue addOperation:oper];
    [oper release];
    return YES;
    
}
- (void)dealloc{
    [zipQueue release], zipQueue = nil;
    [unzipQueue release], unzipQueue = nil;
    [super dealloc];
}

@end

@implementation UnzipOperation
@synthesize toPath,zipFile,password,delegate;
@synthesize isOverWrite = _overWrite;

- (id)initWithZipFile:(NSString *)aZipFile password:(NSString *)aPassword to:(NSString *)aPath overWrite:(BOOL)isOverWrite{
    self = [super init];
    if (self) {
        self.zipFile = aZipFile;
        self.password = aPassword;
        self.toPath = aPath;
        self.isOverWrite = isOverWrite;
    }
    return self;
}
- (void)main{
    // 开始解压
    if ([self.delegate respondsToSelector:@selector(unzipStarted:)]) {
        [self.delegate unzipStarted:self.zipFile];
    }
    BOOL ret = NO;
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    zipArchive.delegate = self;
    do {
        // 打开zip文件
        if ([self.password length] == 0) {
            ret = [zipArchive UnzipOpenFile:self.zipFile];
        }
        else{
            ret = [zipArchive UnzipOpenFile:self.zipFile Password:self.password];
        }
        if (!ret) {
            NSLog(@"[ERR]打开zip文件失败");
            break;
        }
        // 解压文件
        ret = [zipArchive UnzipFileTo:self.toPath overWrite:self.isOverWrite];
        
        if (!ret) {
            NSLog(@"[ERR]解压缩失败");
        }
        
        // 关闭文件
        ret = [zipArchive UnzipCloseFile];
        if (!ret) {
            NSLog(@"[ERR]关闭解压文件失败");
            break;
        }
    } while (0);
    
    if (ret && [self.delegate respondsToSelector:@selector(unzipSuccessed:)]) {
        [self.delegate unzipSuccessed:self.zipFile];
    }
    zipArchive.delegate = nil;
    [zipArchive release];
}

-(void) ErrorMessage:(NSString*) msg{
    if ([self.delegate respondsToSelector:@selector(unzipFailed:errorMessage:)]) {
        [self.delegate unzipFailed:self.zipFile errorMessage:msg];
    }
}
-(BOOL) OverWriteOperation:(NSString*) file{
    if ([self.delegate respondsToSelector:@selector(OverWriteOperation:)]) {
        return [self.delegate OverWriteOperation:file];
    }
    return YES;
}
- (void)dealloc{
    [_zipFile release],_zipFile = nil;
    [_password release],_password = nil;
    [_toPath release],_toPath = nil;
    [super dealloc];
}

@end

@implementation ZipOperation

@synthesize filesArray,toFile,delegate,password;

- (id)initWithFiles:(NSArray *)aFilesArray password:(NSString *)aPassword to:(NSString *)aFile{
    self = [super init];
    if (self) {
        self.filesArray = aFilesArray;
        self.password = aPassword;
        self.toFile = aFile;
    }
    return self;
}

- (void)main{
    // 开始压缩
    if ([self.delegate respondsToSelector:@selector(compressStarted:)]) {
        [self.delegate compressStarted:self.filesArray];
    }
    BOOL ret;
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    zipArchive.delegate = self;
    
    // 创建压缩文件
    if ([self.password length] == 0) {
        ret = [zipArchive CreateZipFile2:self.toFile];
    }
    else{
        ret = [zipArchive CreateZipFile2:self.toFile Password:self.password];
    }
    if (!ret) {
        if ([self.delegate respondsToSelector:@selector(compressFailed:errorMessage:)]) {
            [self.delegate compressFailed:self.filesArray errorMessage:@"[ERR]创建zip文件失败"];
        }
        zipArchive.delegate = nil;
        [zipArchive release];
        return;
    }
    
    // 添加文件至压缩包
    BOOL isDir=NO;	
    
    NSFileManager *fileManager = [NSFileManager defaultManager];	
    
    for (NSString *_filePath in self.filesArray) {
        if ([fileManager fileExistsAtPath:_filePath isDirectory:&isDir]){
            if (isDir) {
                ret = [zipArchive addFileToZip:_filePath newname:[NSString stringWithFormat:@"%@/",[_filePath lastPathComponent]]];
                
                NSArray *subpaths;
                subpaths = [fileManager subpathsAtPath:_filePath];
                for (NSString *_path in subpaths) {
                    NSString *longPath = [_filePath stringByAppendingPathComponent:_path];
                    if([fileManager fileExistsAtPath:longPath isDirectory:&isDir]){
                        if (isDir) {
                            ret = [zipArchive addFileToZip:longPath newname:[NSString stringWithFormat:@"%@/%@/",[_filePath lastPathComponent],_path]];
                        }
                        else{
                            ret = [zipArchive addFileToZip:longPath newname:[NSString stringWithFormat:@"%@/%@",[_filePath lastPathComponent],_path]];
                        }
                        
                    }
                }
            }
            else{
                ret = [zipArchive addFileToZip:_filePath newname:[_filePath lastPathComponent]];
            }
        }
    }
    
    // 关闭文件
    ret = [zipArchive CloseZipFile2];
    if (!ret) {
        if ([self.delegate respondsToSelector:@selector(compressFailed:errorMessage:)]) {
            [self.delegate compressFailed:self.filesArray errorMessage:@"[ERR]关闭压缩文件失败"];
        }
        zipArchive.delegate = nil;
        [zipArchive release];
        return;
    }
    
    // 压缩完成
    if ([self.delegate respondsToSelector:@selector(compressSuccessed:)]) {
        [self.delegate compressSuccessed:self.filesArray];
    }
    zipArchive.delegate = nil;
    [zipArchive release];
}

- (void)dealloc{
    [_filesArray release],_filesArray = nil;
    [_password release],_password = nil;
    [_toFile release],_toFile = nil;
    [super dealloc];
}
@end