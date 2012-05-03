//
//  ViewController.h
//  AsyncZipArchiveDemo
//
//  Created by zhi.zhu on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AsyncZipArchive/AsyncZipArchive.h>

@interface ViewController : UIViewController<AsyncZipArchiveDelegate>{
    AsyncZipArchive *zipArchive;
}

- (IBAction)actionUnzip:(id)sender;
- (IBAction)actionZip:(id)sender;
@end
