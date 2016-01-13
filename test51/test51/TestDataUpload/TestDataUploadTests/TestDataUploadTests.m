//
//  TestDataUploadTests.m
//  TestDataUploadTests
//
//  Created by bubble on 11/13/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "FTPManager.h"
#import "StringHelper.h"
#import "SortHelper.h"


@interface TestDataUploadTests : XCTestCase

@end

@implementation TestDataUploadTests

/*
- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/

/*
-(void)testFTP
{
FTPManager* ftpManager = [[FTPManager alloc] init];
FMServer* svr = [FMServer serverWithDestination:@"192.168.101.226"
username:@"test1"
password:@"123456"];
svr.port = 21;

NSArray* data=[ftpManager contentsOfServer:svr];
if (data!=nil) {
NSLog(@"connect ftp success!");
}

NSString* str = @"";
for (NSDictionary* d in data) {
str = [str stringByAppendingString:[self processDict:d]];
}
NSLog(@"%@",str);

[ftpManager abort];
}

-(NSString*)processDict:(NSDictionary*)dict
{
NSString* name = [dict objectForKey:(id)kCFFTPResourceName];
NSNumber* size = [dict objectForKey:(id)kCFFTPResourceSize];
NSDate* mod = [dict objectForKey:(id)kCFFTPResourceModDate];
NSNumber* type = [dict objectForKey:(id)kCFFTPResourceType];
NSNumber* mode = [dict objectForKey:(id)kCFFTPResourceMode];
NSString* isFolder = ([type intValue] == 4) ? @"(folder) " : @"";
return [NSString stringWithFormat:@"%@ %@--- size %i bytes - mode:%i - modDate: %@\n",name,isFolder,[size intValue],[mode intValue],[mod description]];
}
*/

/*
-(void)testCreateDir
{
    FTPManager* ftpManager = [[FTPManager alloc] init];
    FMServer* svr = [FMServer serverWithDestination:@"192.168.101.226"
                                           username:@"test1"
                                           password:@"123456"];
    svr.port = 21;
    
    //create directory.
    //192.168.101.246/ALS/fsapa29/20151118/hostname/FSAPA29 20151120.csv
    NSString* path=@"";
    NSString* strPath = [path stringByStandardizingPath];
    strPath=[strPath stringByAppendingPathComponent:@"ALS1"];
    strPath=[strPath stringByAppendingPathComponent:@"a11"];
    NSDateFormatter *dateF=[[NSDateFormatter alloc] init];
    [dateF setDateFormat:@"yyyyMMdd"];
    strPath=[strPath stringByAppendingPathComponent:[dateF stringFromDate:[NSDate date]]];
    strPath=[strPath stringByAppendingPathComponent:@"bubble13"];
    //
    BOOL crtBOOL=[ftpManager createNewFolders:strPath atServer:svr];
    if (!crtBOOL) {
        NSLog(@"create directory err!");
    }
    [ftpManager abort];
    
}
*/

/*
-(void)testkillProcess
{
    [self killProcessesNamed:@"TextEdit"];
    //[self killProcessesNamed:@"TestDataUpload"];
}

-(void)killProcessesNamed:(NSString*)appName
{
    for ( id app in [[NSWorkspace sharedWorkspace] runningApplications] )
    {
        if ( [appName isEqualToString:[[app executableURL] lastPathComponent]] )
        {
            [app forceTerminate];
        }
        NSLog(@"%@",[[app executableURL] lastPathComponent]);
    }
    
    //    bool TerminatedAtLeastOne=false;
    //    NSArray *runningApplications = [[NSWorkspace sharedWorkspace] launchedApplications];
    //    NSString *theName;
    //    NSNumber *pid;
    //    for ( NSDictionary *applInfo in runningApplications ) {
    //        if ( (theName = [applInfo objectForKey:@"NSApplicationName"]) ) {
    //            if ( (pid = [applInfo objectForKey:@"NSApplicationProcessIdentifier"]) ) {
    //                //NSLog( @"Process %@ has pid:%@", theName, pid );    //test
    //                if( [theName isEqualToString:@"applicationName"] ) {
    //                    kill( [pid intValue], SIGKILL );
    //                    TerminatedAtLeastOne = true;
    //                }
    //            }
    //        }
    //    }
    return ;
}
*/

/*
-(void)testGetDate
{
    //1.
    NSDateFormatter *dateFileFor=[[NSDateFormatter alloc] init];
    [dateFileFor setDateFormat:@"yyyyMMdd HHmmss"];
    
    NSString *bakDateDir=[dateFileFor stringFromDate:[NSDate date]];
    NSLog(@"%@",bakDateDir);
}
*/

/*
-(void)testCreateDir
{
    //1.
    NSDateFormatter *dateFileFor=[[NSDateFormatter alloc] init];
    [dateFileFor setDateFormat:@"yyyyMMdd HHmmss"];
    
    NSString *bakDateDir=[dateFileFor stringFromDate:[NSDate date]];
    NSLog(@"%@",bakDateDir);
    
    //2.
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString* fileDataDir=[NSString stringWithFormat:@"/Users/bubble/Desktop/%@",bakDateDir];
    
    if ([fm fileExistsAtPath:fileDataDir isDirectory:nil]==NO) {
        [fm createDirectoryAtPath:fileDataDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
*/

/*
-(void)testRenameFile
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"_yyyyMMddHHmmss"];
    
    NSString* fileDataBack=@"/Users/bubble/Desktop";
    NSString* fileBakName=[[[[fileDataBack stringByAppendingPathComponent:@"Untitled.rtf"]stringByDeletingPathExtension]stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]]stringByAppendingPathExtension:[@"Untitled.rtf" pathExtension]];
    
    NSLog(@"%@",fileBakName);
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    [fm moveItemAtPath:@"/Users/bubble/Desktop/Untitled.rtf" toPath:fileBakName error:nil];
    //[fm removeItemAtPath:fileBakName error:nil];
}

-(void)testRemoveFile
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    [fm removeItemAtPath:@"/Users/bubble/Desktop/Untitled.rtf" error:nil];
}
*/

/*
-(void)testCutFile
{
    //1.
    NSDateFormatter *dateFileFor=[[NSDateFormatter alloc] init];
    [dateFileFor setDateFormat:@"yyyyMMdd HHmmss"];
    
    NSString *bakDateDir=[dateFileFor stringFromDate:[NSDate date]];
    NSLog(@"%@",bakDateDir);
    
    //2.
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString* fileDataDir=[NSString stringWithFormat:@"/Users/bubble/Desktop/%@",bakDateDir];
    
    if ([fm fileExistsAtPath:fileDataDir isDirectory:nil]==NO) {
        [fm createDirectoryAtPath:fileDataDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //3.
    NSString *dirBak03=[fileDataDir stringByAppendingPathComponent:@"Untitled.rtf"];
    [fm moveItemAtPath:@"/Users/bubble/Desktop/Untitled.rtf" toPath:dirBak03 error:nil];
}
*/

/*
-(void)testCopyFile
{
    //1.
    NSDateFormatter *dateFileFor=[[NSDateFormatter alloc] init];
    [dateFileFor setDateFormat:@"yyyyMMdd"];
    
    NSString *bakDateDir=[dateFileFor stringFromDate:[NSDate date]];
    NSLog(@"%@",bakDateDir);
    
    //2.
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString* fileDataDir=[NSString stringWithFormat:@"/Users/bubble/Desktop/%@",bakDateDir];
    
    if ([fm fileExistsAtPath:fileDataDir isDirectory:nil]==NO) {
        [fm createDirectoryAtPath:fileDataDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //3.
    NSString *dirBak03=[fileDataDir stringByAppendingPathComponent:@"Untitled.rtf"];
    [fm copyItemAtPath:@"/Users/bubble/Desktop/Untitled.rtf" toPath:dirBak03 error:nil];
}
*/

/*
-(void)testGetFileList
{
    //1.
    NSDateFormatter *dateFileFor=[[NSDateFormatter alloc] init];
    [dateFileFor setDateFormat:@"yyyyMMdd"];
    
    NSString *bakDateDir=[dateFileFor stringFromDate:[NSDate date]];
    NSLog(@"%@",bakDateDir);
    
    //2.
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *fileList =  [[NSArray alloc] init];
    fileList=[fm contentsOfDirectoryAtPath:@"/Users/bubble/Desktop" error:nil];
    for(int i=0;i<[fileList count];i++) {
        NSLog(@"%@",[fileList[i] lastPathComponent]); 
    }
}
*/

/*
-(void)testCheckIsDir
{
    BOOL isDir=FALSE;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm fileExistsAtPath:@"/Users/bubble/Desktop/001" isDirectory:&isDir];
    if(!isDir) {
        NSLog(@"is not dir!");
    }
    
    //
    [fm fileExistsAtPath:@"/Users/bubble/Desktop" isDirectory:&isDir];
    if(isDir) {
        NSLog(@"is dir!");
    }
    
    //
    if ([fm fileExistsAtPath:@"/Users/bubble/Desktop/001" isDirectory:nil]==NO) {
        [fm createDirectoryAtPath:@"/Users/bubble/Desktop/001" withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [fm fileExistsAtPath:@"/Users/bubble/Desktop/001" isDirectory:&isDir];
    if(isDir) {
        NSLog(@"dir exist!");
    }
}
*/

/*
-(void)testCheckIsFile
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm isWritableFileAtPath:@"/Users/bubble/Desktop/001/Untitled.rtf"]==NO) {
        NSLog(@"can not writeable!");
    }
    if([fm isWritableFileAtPath:@"/Users/bubble/Desktop/Untitled.rtf"]==YES) {
        NSLog(@"can writeable!");
    }
    if([fm isWritableFileAtPath:@"/Users/bubble/Desktop/D10_11 Leak Test Plan Rev B.pdf"]==NO) {
        NSLog(@"can not writeable!");
    }
}
*/

/*
-(void)testGetAttr
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *dic= [fm attributesOfItemAtPath:@"/Users/bubble/Desktop/D10_11 Leak Test Plan Rev B.pdf" error:nil];
    for (NSString *key in[dic keyEnumerator]) {
        NSLog(@"====== %@=%@\n",key,[dic valueForKey:key]);
    }
}
*/

/*
-(void)testWriteLog
{
    NSString* strMsg=@"stringByAppendingString";
    @try {
        NSDateFormatter* dateFMT1=[[NSDateFormatter alloc] init];
        [dateFMT1 setDateFormat:@"yyyyMMdd"];
        NSString* fPName=[[dateFMT1 stringFromDate:[NSDate date]] stringByAppendingString:@".log"];
        
        //
        NSFileManager* fm = [[NSFileManager alloc] init];
        NSString *fp01=[[[[NSBundle mainBundle] bundlePath] stringByDeletingPathExtension] stringByDeletingLastPathComponent];
        NSString *fp02=[fp01 stringByAppendingPathComponent:@"log"];
        if ([fm fileExistsAtPath:fp02 isDirectory:nil]==NO) {
            [fm createDirectoryAtPath:fp02 withIntermediateDirectories:YES attributes:nil error:nil];
        }

        NSString *fpath=[fp02 stringByAppendingPathComponent:fPName];
        if ([fm fileExistsAtPath:fpath]==NO) {
            [fm createFileAtPath:fpath contents:nil attributes:nil];
        }
        else{
            NSDictionary *dic= [fm attributesOfItemAtPath:fpath error:nil];
            if([[dic objectForKey:@"NSFileSize"] doubleValue]>1024*1024*5)
            {
                [fm removeItemAtPath:fpath error:nil];
                [fm createFileAtPath:fpath contents:nil attributes:nil];
            }
        }
        
        //
        NSFileHandle *logFile= [NSFileHandle fileHandleForWritingAtPath:fpath];
        [logFile seekToEndOfFile];
        NSMutableData *buffer = [[NSMutableData alloc] init];
        NSDateFormatter* dateFMT2=[[NSDateFormatter alloc] init];
        [dateFMT2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString* logDate=[dateFMT2 stringFromDate:[NSDate date]];
        [buffer appendData:[logDate dataUsingEncoding:NSUTF8StringEncoding]];
        [buffer appendData:[@":\t" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [buffer appendData:[strMsg dataUsingEncoding:NSUTF8StringEncoding]];
        [buffer appendData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [logFile writeData:buffer];
        [logFile closeFile];
    }
    @catch (NSException *exception) {
        
    }
}
*/

/*
-(void)testTrim
{
    NSString* str1=@"  123abc 456def    ";
    NSLog(@"\"%@\"",str1);
    NSString* str2=[str1 stringByTrimmingBothSideWhitespace];
    NSLog(@"\"%@\"",str2);
    
    NSArray* arr1=[str1 convertToArray];
    for(NSString* s in arr1)
    {
        NSLog(@"\"%@\"",s);
    }
}
*/

/*
-(void)testGetMysqlString
{
    MysqlString* mysqlstr=[[MysqlString alloc]init];
    [mysqlstr addInsertParam:@"testdb" Field:@"field1" Value:@"1"];
    [mysqlstr addInsertParam:@"testdb" Field:@"field2" Value:@"2"];
    [mysqlstr addInsertParam:@"testdb" Field:@"field3" Value:@"3"];
    [mysqlstr addInsertParam:@"testdb" Field:@"field4" Value:@"4"];
    [mysqlstr addInsertParam:@"testdb" Field:@"field5" Value:@"5"];
    NSLog(@"%@",[mysqlstr stringInsertSQL]);
}
*/


/*
-(void)testgetBlockFromFile
{
    NSString* path=@"file:///TestTools/AlsFlexTest_OQC_v1.5.3a10/LogsFolder/calibration_summary.csv";
    NSRange rang=[path rangeOfString:@"file:"];
    if (rang.location==0) {
        path=[path substringFromIndex:rang.location+5];
    }
    NSFileManager *fm = [[NSFileManager alloc] init];
    if ([fm fileExistsAtPath:path isDirectory:false]==NO){
        return ;
    }
    
    //c++ include stdio.h
    FILE *wordFile=fopen([path UTF8String], "r");
    char wordData[1500]={0};
    //fgets(wordData,10000,wordFile);
    fread(wordData, 1, 1500, wordFile);
    
    fclose(wordFile);
    
    wordData[strlen(wordData)-1] ='\0';
    
    NSString* strstr=[NSString stringWithUTF8String:wordData];
    NSLog(@"%@",strstr);
    
    return ;//[NSString stringWithUTF8String:wordData];
}
*/

/*
-(void)testGetAttr
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *dic= [fm attributesOfItemAtPath:@"/Users/bubble/Desktop/MYAPP.ZIP" error:nil];
    for (NSString *key in[dic keyEnumerator]) {
        NSLog(@"====== %@=%@\n",key,[dic valueForKey:key]);
    }
}
*/


/*
#define kSize 20
#define kMax 100

-(void)testArrSort
{
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:kSize];
    for (int i =0;i<kSize;i++) {
        u_int32_t x = arc4random() % kMax;//0~kMax
       NSNumber *num = [[NSNumber alloc] initWithInt:x];
        [data addObject:num];
    }
        
    SortHelper* sort=[[SortHelper alloc]init];
    NSLog(@"排序前的数据：%@",[data description]);
    
    
    //测试传值
    //NSArray* arr1=[sort selectSortWithArray:data];
    //NSArray* arr1=[sort insertSortWithArray:data];
    //NSArray* arr1=[sort quickSortWithArray:data];
    //NSLog(@"排序后的数据：%@",[arr1 description]);
    
    
    //测试传引用
    //[sort selectSortWithArray1:&data];
    //[sort insertSortWithArray1:&data];
    [sort quickSortWithArray1:&data];
    NSLog(@"排序后的数据：%@",[data description]);
}
*/

/*
-(void)testRWTXT
{
    [self setEndLineNow:@"abc" Line:123];
}

-(NSString*)readLineAsString:(FILE*)file
{
    char buffer[4096];
    NSMutableString *result=[NSMutableString stringWithCapacity:255];
    int charsRead;
    do{
        if (fscanf(file, "%4095[^\n]%n%*c",buffer,&charsRead)==1) {
            [result appendFormat:@"%s",buffer];
        }
        else
            break;
    }while (charsRead==4095);
    
    return result;
}


-(void)setEndLineNow:(NSString*)part Line:(double)line
{
    NSString* path1=@"/Data/startline.setting";
    NSString* path2=@"/Data/startline.setting1";
    
    if (access([path2 UTF8String], 0)==0) {
        remove([path2 UTF8String]);
    }
    FILE* f2=fopen([path2 UTF8String], "a");
    if (f2) {
        if (access([path1 UTF8String], 0)==0) {
            FILE* f1=fopen([path1 UTF8String], "r");
            if (f1) {
                while (!feof(f1)) {
                    NSLog(@"%@",[self readLineAsString:f1]);
                }
                fclose(f1);
            }
        }
        else{
            for (int i=0; i<5; i++) {
                char buf2[255]={0};
                sprintf(buf2, "#param:=%s,%1.0f,%d\n",[part UTF8String],line,i);
                //fwrite的第二个参数要用strlen,不能用sizeof
                fwrite(buf2, strlen(buf2), 1, f2);
            }
        }
    }
    fclose(f2);
    
    //
    if (access([path2 UTF8String], 0)==0) {
        if (access([path1 UTF8String], 0)==0) {
            remove([path1 UTF8String]);
        }
        rename([path2 UTF8String], [path1 UTF8String]);
    }
}
*/

/*
-(void)setEndLineNow:(NSString*)part Line:(double)line
{
    NSString* path1=@"/Data/startline.setting";
    NSString* path2=@"/Data/startline.setting1";
    
    if (access([path2 UTF8String], 0)==0) {
        remove([path2 UTF8String]);
    }
    FILE* f2=fopen([path2 UTF8String], "a");
    if (f2) {
        if (access([path1 UTF8String], 0)==0) {
            FILE* f1=fopen([path1 UTF8String], "r");
            char buf[255]={0};
            if (f1) {
                while (!feof(f1)) {
                    if (fgets(buf, sizeof(buf), f1)) {
                        printf("%s",buf);
                    }
                }
                fclose(f1);
            }
        }
        else{
            for (int i=0; i<5; i++) {
                char buf2[255]={0};
                sprintf(buf2, "#param:=%s,%1.0f,%d\n",[part UTF8String],line,i);
                //fwrite的第二个参数要用strlen,不能用sizeof
                fwrite(buf2, strlen(buf2), 1, f2);
            }
        }
    }
    fclose(f2);
    
    //
    if (access([path2 UTF8String], 0)==0) {
        if (access([path1 UTF8String], 0)==0) {
            remove([path1 UTF8String]);
        }
        rename([path2 UTF8String], [path1 UTF8String]);
    }
}
*/

/*
-(bool)getPathByDeletePrefix1:(NSString**)strPath
{
    //传引用
    NSRange rang=[*strPath rangeOfString:@"file:"];
    if (rang.location==0) {
        *strPath=[*strPath substringFromIndex:rang.location+5];
    }
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    if ([fm fileExistsAtPath:*strPath isDirectory:false]==FALSE){
        return false;
    }
    
    //    if (access([*strPath UTF8String], 0)!=0) {
    //        return false;
    //    }
    
    return true;
}

-(bool)getPathByDeletePrefix2:(NSString*)strPath
{
    //传引用
    NSRange rang=[strPath rangeOfString:@"file:"];
    if (rang.location==0) {
        strPath=[strPath substringFromIndex:rang.location+5];
    }
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    if ([fm fileExistsAtPath:strPath isDirectory:false]==FALSE){
        return false;
    }
    
//        if (access([strPath UTF8String], 0)!=0) {
//            return false;
//        }
    return true;
}

-(void)testCheckFileisExist
{
//    NSString* str1=@"/Users/bubble/Desktop/a/FSAPL88.txt";
//    NSString* str2=@"file:///Users/bubble/Desktop/a/FSAPL88 .txt";
//    bool res=[self getPathByDeletePrefix1:&str1];
//    bool res1=[self getPathByDeletePrefix1:&str2];
    
}
*/

/*
-(void)testReadFile
{
    //NSString* path=@"/data/1.csv";
    NSString* path=@"/data/FSAPL88.txt";
    NSString* strHead=nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]==NO) {
        strHead=nil;
    }
    else{
        NSError* err;
        strHead=[NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&err];
    }
}
*/

-(void)testStringTest
{
    NSString *str1=@"abcd";
    NSString *str2=@"abcD";
    if([str1 compare:str2 options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        //NSLog(@"hello");
    }
    
    
    NSString *fp01=[[[[NSBundle mainBundle] bundlePath] stringByDeletingPathExtension] stringByDeletingLastPathComponent];
    NSLog(@"%@",fp01);
    NSString *fp02=[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
    NSLog(@"%@",fp02);
    
    NSString* strPath=@"/Data/FSAPL851.csv";
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:strPath isDirectory:false]==NO){
        NSLog(@"false");
    }
    
    if ([fm fileExistsAtPath:[strPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "] isDirectory:false]==NO){
        NSLog(@"false");
    }
    
    
}

@end
