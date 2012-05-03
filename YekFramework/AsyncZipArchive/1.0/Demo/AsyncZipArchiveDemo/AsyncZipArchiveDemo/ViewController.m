//
//  ViewController.m
//  AsyncZipArchiveDemo
//
//  Created by zhi.zhu on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (id)init{
    self = [super init];
    if (self) {
        zipArchive = [[AsyncZipArchive alloc] initWithArchiveDelegate:self maxConcurrentOperationCount:3];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        zipArchive = [[AsyncZipArchive alloc] initWithArchiveDelegate:self maxConcurrentOperationCount:3];
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc{
    [zipArchive release],zipArchive = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)actionZip:(id)sender{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *zipFile2 = [[NSBundle mainBundle] pathForResource:@"testDir" ofType:nil];
    NSString *zipFile3 = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"xlsx"];
    NSString *toPath2;
    for (int i = 0; i<5; i++) {
        toPath2 = [documentPath stringByAppendingFormat:@"/test_%d.zip",i];
        [zipArchive zipFiles:[NSArray arrayWithObjects:zipFile2,zipFile3, nil] password:nil to:toPath2];
    }
}

- (void)actionUnzip:(id)sender{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *zipFile = [[NSBundle mainBundle] pathForResource:@"test"ofType:@"zip"];
    NSString *toPath = [documentPath stringByAppendingString:@"/test"];
    for (int i = 0; i<10; i++) {
        [zipArchive unzipFile:zipFile password:nil to:[toPath stringByAppendingFormat:@"%d",i] overWrite:NO];
    }
}

#pragma mark - delegate
- (void)unzipStarted:(NSString *)file{
    NSLog(@"解压开始:%@",[file lastPathComponent]);
}
- (void)unzipSuccessed:(NSString *)file{
    NSLog(@"解压成功:%@",[file lastPathComponent]);
}
- (void)unzipFailed:(NSString *)file errorMessage:(NSString *)msg{
    NSLog(@"解压失败:%@",msg);
}

- (BOOL)OverWriteOperation:(NSString *)file{
    return YES;
}

- (void)compressStarted:(NSArray *)fileArray{
    NSLog(@"压缩开始");
}

- (void)compressSuccessed:(NSArray *)fileArray{
    NSLog(@"压缩成功");
}

- (void)compressFailed:(NSArray *)fileArray errorMessage:(NSString *)msg{
    NSLog(@"压缩失败:%@",msg);
}
@end
