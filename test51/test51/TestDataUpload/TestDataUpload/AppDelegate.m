//
//  AppDelegate.m
//  test6
//
//  Created by bubble on 9/23/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#import "AppDelegate.h"
#import "AnalyzeData.h"
#import "UsePlist.h"
#import "UserLog.h"



//global variable
NSString* const  AppWindowTitle = @"TestDataUpload v1.49.20160113";


//
@implementation FileAttr

@synthesize fileName;
@synthesize fileCreateTime;


@end


//
@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

-(id)init
{
    self=[super init];
    if (self) {
        //
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    
    [[self window]setTitle:AppWindowTitle];
    @autoreleasepool {
        UsePlist* plist=[[UsePlist alloc]initForSys:self];
        [plist getSysConfig];
        [plist getUserState];
    }
    
    //[self getUserState];
    
    
#ifdef TARGET_OS_X_10_9
    [btnLogin highlight:true];
#else
    [btnLogin setHighlighted:true];
#endif
    [btnSetting setEnabled:false];
    [btnReUpload setEnabled:true];
    [btnFtpUpload setEnabled:true];
    [mnSystem setEnabled:true];
    [mainTab selectTabViewItemAtIndex:0];
    bLogin=false;
    bStartRunUpload=true;
    tsTotal=0.0;
    tsPass=0.0;
    tsFail=0.0;
    tsRate=0.0;
    logLine=0.0;
    
    errBarcodeChk=0;
    errDBLink=0;
    countHourProducts=0;
    

    //
    strLocalIP=[self getLocalIP];
    
    //
//    myThread = [[NSThread alloc] initWithTarget:self
//                                       selector:@selector(run)
//                                         object:nil];
    
    _lock = [[NSLock alloc] init];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [myThread cancel];
    
    @autoreleasepool {
        UsePlist* plist=[[UsePlist alloc]initForSys:self];
          [plist saveUserState];
    }
    
    if (_lock) {
        [_lock unlock];
    }
}

-(IBAction)SystemLogin:(id)sender
{
    [self writeLog:@"action:Login System"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSApp beginSheet:theSheet
           modalForWindow:(NSWindow *)_window
            modalDelegate:self
           didEndSelector:nil
              contextInfo:nil];
    });
}

-(IBAction)CloseSystemLogin:(id)sender
{
    bLogin=false;
    [btnSetting setEnabled:false];
    [mnSystem setEnabled:false];
#ifdef TARGET_OS_X_10_9
    [btnLogin highlight:true];
#else
    [btnLogin setHighlighted:true];
#endif
    if (sender==btnLoginOK) {
        if ([[txtLoginPWD stringValue] compare:@"1q2w3e"]==NSOrderedSame) {
            [btnSetting setEnabled:true];
            [mnSystem setEnabled:true];
#ifdef TARGET_OS_X_10_9
            [btnLogin highlight:false];
            [btnSetting highlight:true];
#else
            [btnLogin setHighlighted:false];
            [btnSetting setHighlighted:true];
#endif
            bLogin=true;
        }
    }
    
    [NSApp endSheet:theSheet];
    [theSheet orderOut:sender];
    [txtLoginPWD setStringValue:@""];
}

-(IBAction)SystemAbout:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSApp beginSheet:AboutSheet
           modalForWindow:(NSWindow *)_window
            modalDelegate:self
           didEndSelector:nil
              contextInfo:nil];

    });
    
    [txtVersion setStringValue:AppWindowTitle];
    [txtHelpContent setString:[self getReadMeContent]];
}

-(IBAction)closeSystemAbout:(id)sender
{
    [NSApp endSheet:AboutSheet];
    [AboutSheet orderOut:sender];
}

-(IBAction)SystemSetting:(id)sender
{
    [self writeLog:@"action:Setting System"];
    if (bLogin==true) {
        SettingDlg* dialogCtl;
        dialogCtl = [[SettingDlg alloc] initWithWindowNibName:@"SettingDlg"];
        dialogCtl.strPartNum=[txtPartNo stringValue];
        [SettingDlg load];
        [NSApp runModalForWindow:[dialogCtl window]];
        [btnSetting setEnabled:false];
#ifdef TARGET_OS_X_10_9
        [btnLogin highlight:true];
#else
        [btnLogin setHighlighted:true];
#endif
        bLogin=false;
        
        //
        @autoreleasepool {
            UsePlist* plist=[[UsePlist alloc]initForSys:self];
            [plist getSysConfig];
        }
    }
}

-(IBAction)StartUpload:(id)sender
{
    //
    [mainTab selectTabViewItemAtIndex:0];
    
    @autoreleasepool {
        //此处不能再次获取配置参数，当点击停止上传时记录行数的参数被获取又被线程改变，导致计数不准确
        
        [self writeLog:@"action:Start Upload"];
        NSString* strErr;
        
        //
        strErr=@"配置文件config.list不存在!";
        @autoreleasepool {
            UsePlist* plist=[[UsePlist alloc]initForSys:self];
            if ([plist checkConfigFileExist]==false) {
                [self showAlertMsg:strErr];
                [self showErr:strErr];
                return;
            }
        }
        
        //
        strErr=@"连接数据库失败!";
        if ([self checkDBConnect]==false) {
            [self showAlertMsg:strErr];
            [self showErr:strErr];
            return;
        }
        
        //
        strErr=@"连接FTP server失败!";
        if ([self checkFTPConnect]==false && bUseFTP==true) {
            [self showAlertMsg:strErr];
            [self showErr:strErr];
            return;
        }
        
        //
        if (bStartRunUpload) {
            strErr=@".csv/.txt文件不存在,\n1)文件没有生成,2)文件被移动到backup文件夹!";
            if ([self isFileExist:strFilePath]==NO) {
                [self showAlertMsg:strErr];
                [self showErr:strErr];
                return;
            }
        }
        
        //
        [self showRunState:1 State:1];
        [self showRunState:2 State:1];
        //[self showRunState:3 State:1];
        [self showRunState:4 State:1];
        [txtHello setStringValue:[self getFileType]];
        //strLocalIP=[self getLocalIP];
        errBarcodeChk=0;
        
        //
        bool bEnableBTN=true;
        @try {
            if ([self checkUserInput]) {
#ifdef TARGET_OS_X_10_9
#else
                [btnStartUpload setAccessibilityFocused:true];
#endif
                if (bStartRunUpload) {
                    [btnStartUpload setTitle:@"停止上传"];
                    //[pgWork startAnimation:self];
                    //create thread.
                    if ([myThread isExecuting]==false) {
                        myThread = [[NSThread alloc] initWithTarget:self
                                                           selector:@selector(run)
                                                             object:nil];
                        [myThread start];
                        [self writeLog:@"create and start myThread"];
                        bEnableBTN=false;
                    }
                }
                else
                {
                    [btnStartUpload setTitle:@"开始上传"];
                    //[pgWork stopAnimation:self];
                    if ([myThread isExecuting] ) {
                        //set thread exit tag.
                        [myThread cancel];
                        [self writeLog:@"cancel myThread"];
                        bEnableBTN=true;
                    }
                }
                bStartRunUpload=!bStartRunUpload;
            }
            
            //
            [btnLogin setEnabled:bEnableBTN];
            [btnReUpload setEnabled:bEnableBTN];
            [btnFtpUpload setEnabled:bEnableBTN];
        }
        @catch (NSException *exception) {
            [self writeLog:[exception description]];
        }
        @finally {
            
        }
    }
}

-(bool)checkUserInput
{
    NSString* strErr=nil;
    [self writeLog:@"call function: checkUserInput()"];

    //
    NSMutableArray *txtArr=[NSMutableArray array];
    [txtArr addObject:txtBarcodeFormat];
    [txtArr addObject:txtPartNo];
    [txtArr addObject:txtWorkNo];
    [txtArr addObject:txtWorkOrder];
    [txtArr addObject:txtFixtureNo];
    [txtArr addObject:txtLineNo];
    
    strBarcodeFormat=[txtBarcodeFormat stringValue];
    strPartNo=[txtPartNo stringValue];
    strWorkNo=[txtWorkNo stringValue];
    strWorkOrder=[txtWorkOrder stringValue];
    strFixtureNo=[txtFixtureNo stringValue];
    strLineNo=[txtLineNo stringValue];
    
    for (int i=0; i<[txtArr count]; i++) {
        if ([[txtArr[i] stringValue] compare:@""]==NSOrderedSame){
            switch (i) {
                case 0: strErr=@"请输入条码格式，通配符为星号(*)";    break;
                case 1: strErr=@"请输入料号!";          break;
                case 2: strErr=@"请输入工号!";          break;
                case 3: strErr=@"请输入工令!";          break;
                case 4: strErr=@"请输入治具编号!";       break;
                case 5: strErr=@"请输入线体!";          break;
                default:
                    break;
            }
            [self showAlertMsg:strErr];
            [self showErr:strErr];
            return false;
        }
    }

    return true;
}

-(void)showAlertMsg:(NSString*)msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"来自TestdataUpload的消息:"];
            [alert setInformativeText:msg];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert setHelpAnchor:@"ddd"];
            [alert runModal];
        }
    });
}

-(NSString*)getTestDateTime:(_LOCALDATETIME)datetime
{
    NSDateFormatter* fm=[[NSDateFormatter alloc] init];
    switch (datetime) {
        case 0: [fm setDateFormat:@"yyyyMMdd"];                      break;
        case 1: [fm setDateFormat:@"HHmmss"];                        break;
        case 2: [fm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];           break;
        default:
            break;
    }
    return [fm stringFromDate:[NSDate date]];
}

-(void)showRun:(NSString *)msg
{
    if (logLine>500) {
        [self clearMyTextView];
        logLine=0.0;
    }
    //[self appendToMyTextView:msg];
    [self appendToMyTextView:txtRunView
                    ViewText:[NSString stringWithFormat:@"<%@>;%@\n",[self getTestDateTime:LOCAL_DATE_TIME],msg]];
}

-(void)showErr:(NSString *)msg
{
    //
    errLine++;
    if (errLine>500) {
        [self clearMyTextView];
        errLine=0.0;
    }
    [self appendToMyTextView:txtErrView
                    ViewText:[NSString stringWithFormat:@"<%@>:%@\n",[self getTestDateTime:LOCAL_DATE_TIME],msg]];
    
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            //[mainTab selectTabViewItemAtIndex:3];
            
            //
            NSTextStorage* textViewContent = [txtErrView textStorage];
            if ([textViewContent length]>0) {
                //get the range of the entire run of text
                NSRange area = NSMakeRange(0, [textViewContent length]);
                //remove existing coloring
                [textViewContent removeAttribute:NSForegroundColorAttributeName range:area];
                //add new coloring
                [textViewContent addAttribute:NSForegroundColorAttributeName
                                        value:[NSColor redColor]
                                        range:area];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    });
}

-(void)appendToMyTextView:(NSTextView*)myView ViewText:(NSString*)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            if (text) {
                NSAttributedString* attr = [[NSAttributedString alloc] initWithString:text];
                [[myView textStorage] appendAttributedString:attr];
                [myView scrollRangeToVisible:NSMakeRange([[myView string] length], 0)];
            }
        }
    });
}

-(void)clearMyTextView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [txtRunView setString:@""];
        }
    });
}

-(void)run {
    while (TRUE) {
        @try {
            [NSThread sleepForTimeInterval:readPoll];

            //1.上传数据到mysql
            switch ([self getDataFileType]) {
                case ALS_X137:
                    @autoreleasepool {
                        AnalyzeData* an=[[AnalyzeData alloc]init:self];
                        [an getCommaData:strFilePath];
                    }
                    break;
                case Prox_N56:
                case Prox_N66:
                case Prox_N71:
                    @autoreleasepool {
                        AnalyzeData* an=[[AnalyzeData alloc]init:self];
                        [an getCommaData:[an getFilePathByCreateTimeAndProx:strFilePath]];
                    }
                    break;
                case ALS_N69:
                case ALS_X109:
                    @autoreleasepool {
                        AnalyzeData* an=[[AnalyzeData alloc]init:self];
                        [an getTabData:strFilePath];
                    }
                    break;
                case Mic_X35:
                    @autoreleasepool {
                        AnalyzeData* an=[[AnalyzeData alloc]init:self];
                        [an getMicData:[an getFilePathByCreateTimeAndPart:strFilePath]];
                    }
                    break;
                case Mic_D10:
                    @autoreleasepool {
                        AnalyzeData* an=[[AnalyzeData alloc]init:self];
                        [an getCommaData:[an getFilePathByCreateTimeAndPart:strFilePath]];
                    }
                    break;
                case ALS_J127:
                    @autoreleasepool {
                        AnalyzeData* an=[[AnalyzeData alloc]init:self];
                        [an getCommaData:[an getBansheeFilePathByCreateTime:strFilePath]];
                    }
                    break;
                default:
                    break;
            }
            
            //创建backup文件夹
            [self createDataFolder];
            
            //2.上传文件到FTP
            switch ([self getDataFileType]) {
                case ALS_X137:
                case ALS_N69:
                case ALS_X109:
                    [self autoUploadFTP:strFilePath];
                    break;
                case Prox_N56:
                case Prox_N66:
                case Prox_N71:
                    @autoreleasepool {
                        AnalyzeData* an=[[AnalyzeData alloc]init:self];
                        [self autoUploadFTP:[an getFilePathByCreateTimeAndProx:strFilePath]];
                    }
                    break;
                case Mic_X35:
                case Mic_D10:
                    @autoreleasepool {
                        AnalyzeData* an=[[AnalyzeData alloc]init:self];
                        [self autoUploadFTP:[an getFilePathByCreateTimeAndPart:strFilePath]];
                    }
                    break;
                case ALS_J127:
                    @autoreleasepool {
                        AnalyzeData* an=[[AnalyzeData alloc]init:self];
                        [self autoUploadFTP:[an getBansheeFilePathByCreateTime:strFilePath]];
                    }
                    break;
                default:
                    break;
            }
            
            
            //3.将lastdate设置为当前的日期
            @autoreleasepool {
                UsePlist* plist=[[UsePlist alloc]initForSys:self];
                [plist saveWorkDate];
            }
            
            //you want to exit this thread you should check the tag of thread.
            if ([myThread isCancelled]) {
                [NSThread exit];
                myThread=nil;
                [self writeLog:@"exit myThread"];
            }
            if (_lock) {
                [_lock lock];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
}

-(void)createDataFolder
{
    [self writeLog:@"call function: createDataFolder()"];
    
    @autoreleasepool {
        @try {
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString* strDir=[NSString stringWithFormat:@"%@//%@",[strFilePath stringByDeletingLastPathComponent],@"Backup"];
            if([fm fileExistsAtPath:strDir isDirectory:nil]==NO)
            {
                [fm createDirectoryAtPath:strDir
              withIntermediateDirectories:YES
                               attributes:nil error:nil];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            
        }
    }
}

-(NSString*)getNowDate
{
    NSDateFormatter* date1=[[NSDateFormatter alloc] init];
    [date1 setDateFormat:@"yyyyMMdd"];
    return [date1 stringFromDate:[NSDate date]];
}

-(bool)uploadData:(NSString*)barcode TestResult:(NSString*)result TestDate:(NSString*)date DataTable:(_DATATABLE)table
{
    if (!strDBIP) {
        return false;
    }
    
    //check barcode
    NSString* strErr=@"条码格式不正确!";
    if (bUseCheckBarcode) {
        if ([self checkBarcode:barcode BarFormat:strBarcodeFormat]==false) {
            bCheckBar=false;
            errBarcodeChk++;
            if (errBarcodeChk<4) {
                 [self showAlertMsg:strErr];
            }
            [self showErr:[NSString stringWithFormat:@"%@\t%@",barcode,strErr]];
            return false;
        }
    }
    bCheckBar=true;
    errBarcodeChk=0;
    
    //
    [self writeLog:@"call function: uploadData()"];
    @try {
        @autoreleasepool {
            MysqlDB* db=[[MysqlDB alloc]init];
            MysqlString* mysqlstr=[[MysqlString alloc]init];
            NSString* strSQL;
            if ([db connect:strDBIP
                       User:strDBID
                   Password:strDBPWD
                         DB:strDBName]==true) {
                bDBConnect=true;
                switch (table) {
                    case MYSQL_ALS_ICT_DATA:       strSQL=[NSString stringWithFormat:@"%@.ict_data",strDBName];       break;
                    case MYSQL_Prox_FLUKE_DATA:    strSQL=[NSString stringWithFormat:@"%@.fluke_data",strDBName];     break;
                    default:
                        break;
                }
            }
            else
            {
                bDBConnect=false;
                [db close];
                [self writeLog:@"-->connect to mysql error!"];
                return false;
            }
            
            //
            [mysqlstr addInsertParam:strSQL Field:@"barcode" Value:barcode];
            [mysqlstr addInsertParam:strSQL Field:@"tresult" Value:result];
            [mysqlstr addInsertParam:strSQL Field:@"tdate" Value:date];
            [mysqlstr addInsertParam:strSQL Field:@"ttime" Value:date];
            [mysqlstr addInsertParam:strSQL Field:@"ipad" Value:strLocalIP];
            [mysqlstr addInsertParam:strSQL Field:@"mno" Value:strFixtureNo];
            [mysqlstr addInsertParam:strSQL Field:@"pno" Value:strWorkNo];
            [mysqlstr addInsertParam:strSQL Field:@"lno" Value:strLineNo];
            [mysqlstr addInsertParam:strSQL Field:@"wno" Value:strWorkOrder];
            [mysqlstr addInsertParam:strSQL Field:@"ftp" Value:[self getFTPPath]];

            [db insertData:[mysqlstr stringInsertSQL]];
            [self writeLog:[NSString stringWithFormat:@"-->sql string:%@",[mysqlstr stringInsertSQL]]];
            //NSLog(@"-->sql string:%@",[mysqlstr stringInsertSQL]);
            [db close];
            hourProducts++;
            return true;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        [self writeLog:[NSString stringWithFormat:@"-->upload date failed!\n error info:%@",[exception description]]];
        [self showRunState:1 State:0];
    }
    @finally {
        
    }
    return false;
}

-(void)showRate:(NSString*)result
{
    if (!bCheckBar) {
        return;
    }
    if (result!=nil) {
        if ([result compare:@"PASS" options:NSCaseInsensitiveSearch]==NSOrderedSame) {  tsPass++;  }
        if ([result compare:@"FAIL" options:NSCaseInsensitiveSearch]==NSOrderedSame) {  tsFail++;  }
        [self showRate];
    }
}

-(void)showRate
{
    tsTotal=tsPass+tsFail;
    if (tsTotal>0) {
        tsRate=(tsPass*100.0)/tsTotal;
    }
    
    [self showRunState:true];
    [txtSTTotal setStringValue:[NSString stringWithFormat:@"测试总数:%1.0f",tsTotal]];
    [txtSTPass setStringValue:[NSString stringWithFormat:@"良品数:%1.0f",tsPass]];
    [txtSTFail setStringValue:[NSString stringWithFormat:@"不良品数:%1.0f",tsFail]];
    [txtSTRate setStringValue:[NSString stringWithFormat:@"良率:%1.3f%%",tsRate]];
}

-(void)uploadFtpFile:(NSString*) strPath
{
    if (!bUseFTP) {
        return;
    }
    
    //
    [self writeLog:@"call function: uploadFtpFile()"];
    [self writeLog:[NSString stringWithFormat:@"-->ftp file path:%@",strPath]];
    @autoreleasepool {
        FTPManager* ftpManager = [[FTPManager alloc] init];
        FMServer* svr = [FMServer serverWithDestination:strFTPIP
                                               username:strFTPID
                                               password:strFTPPWD];
        svr.port = [strFTPPort intValue];
        
        //create directory.
        NSString* Path = [@"" stringByStandardizingPath];
        Path=[Path stringByAppendingPathComponent:strFTPDir];
        Path=[Path stringByAppendingPathComponent:strPartNo];
        NSDateFormatter *dateF=[[NSDateFormatter alloc] init];
        [dateF setDateFormat:@"yyyyMMdd"];
        Path=[Path stringByAppendingPathComponent:[dateF stringFromDate:[NSDate date]]];
        Path=[Path stringByAppendingPathComponent:[self getHostName]];
        //
        BOOL crtBOOL=[ftpManager createNewFolders:Path atServer:svr];
        if (!crtBOOL) {
            [self writeLog:@"-->create directory err!"];
        }
        [ftpManager abort];
        
        //upload file.
        FMServer* svr1 = [FMServer serverWithDestination:[strFTPIP stringByAppendingPathComponent:Path]
                                                username:strFTPID
                                                password:strFTPPWD];
        BOOL res=[ftpManager uploadFile:[NSURL URLWithString:strPath] toServer:svr1];
        if (res) {
            [self writeLog:@"-->Upload file successed!"];
            [self showRunState:2 State:1];
        }
        else
        {
            [self writeLog:@"-->Upload file failed!"];
            [self showRunState:2 State:0];
        }
        [ftpManager abort];
    }
}

-(IBAction)uploadFTP:(id)sender
{
    [self writeLog:@"action:to upload ftp file!"];
    if (!bUseFTP) {
        return;
    }
    
    @autoreleasepool {
        UsePlist* plist=[[UsePlist alloc]initForSys:self];
        if ([plist checkConfigFileExist]==false) {
            return;
        }
    }

    if (![self checkUserInput]) {
        return;
    }
    if ([[txtPartNo stringValue] compare:@"" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
        [self showAlertMsg:@"请输入料号!"];
        return;
    }
    if (strFTPFilePath==nil) {
        return;
    }

    //上传文件到FTP
    if ([self getDataFileType]==Prox_N56 ||
        [self getDataFileType]==Prox_N66 ||
        [self getDataFileType]==Prox_N71) {
        @autoreleasepool {
            AnalyzeData* an=[[AnalyzeData alloc]init:self];
            NSString* strFTP=[an getFilePathByCreateTimeAndProx:strFTPFilePath];
            if (![self isFileExist:strFTP]) {
                return;
            }
            //适用于处理N56/N66/N71的距感测试数据
            [self uploadFtpFile:strFTP];
        }
    }
    else {
        if (![self isFileExist:strFTPFilePath]) {
            return;
        }
        [self uploadFtpFile:strFTPFilePath];
    }
}

-(NSString*) getHostName
{
    //#include <SystemConfiguration/SystemConfiguration.h>
    // Returns NULL/nil if no computer name set, or error occurred. OSX 10.1+
    NSString *computerName = (NSString *)CFBridgingRelease(SCDynamicStoreCopyComputerName(NULL, NULL));
    
    // Returns NULL/nil if no local hostname set, or error occurred. OSX 10.2+
    //NSString *localHostname = (NSString *)CFBridgingRelease(SCDynamicStoreCopyLocalHostName(NULL));
    //return computerName;
    return [computerName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
}

-(IBAction)clrStatistics:(id)sender
{
    tsTotal=0.0;
    tsPass=0.0;
    tsFail=0.0;
    tsRate=0.0;
    hourProducts=0.0;
    
    [txtSTTotal setStringValue:[NSString stringWithFormat:@"测试总数:%1.0f",0.0]];
    [txtSTPass setStringValue:[NSString stringWithFormat:@"良品数:%1.0f",0.0]];
    [txtSTFail setStringValue:[NSString stringWithFormat:@"不良品数:%1.0f",0.0]];
    [txtSTRate setStringValue:[NSString stringWithFormat:@"良率:%1.3f%%",0.0]];
    [txtHourProduct setStringValue:[NSString stringWithFormat:@"产量(每60s):%1.0f",0.0]];
}

-(IBAction)reloadData:(id)sender
{
    @autoreleasepool {
        UsePlist* plist=[[UsePlist alloc]initForSys:self];
        if ([plist checkConfigFileExist]==true && [self checkUserInput]==true) {
            readRow=1;
            @autoreleasepool {
                AnalyzeData* an=[[AnalyzeData alloc]init:self];
                
                if ([self getDataFileType]==Prox_N56 ||
                    [self getDataFileType]==Prox_N66 ||
                    [self getDataFileType]==Prox_N71) {
                    @autoreleasepool {
                        AnalyzeData* an=[[AnalyzeData alloc]init:self];
                        [an saveStartLine:[[an getFilePathByCreateTimeAndProx:strFilePath] lastPathComponent] Line:0];
                    }
                }
                else{
                    [an saveStartLine:strPartNo Line:0];
                }
            }
        }
    }
}

-(bool)isMidNight
{
    @autoreleasepool {
        UsePlist* plist=[[UsePlist alloc]initForSys:self];
        if ([[self getNowDate] compare:[plist getWorkDate] options:NSCaseInsensitiveSearch]!=NSOrderedSame) {
            NSLog(@"%@\n%@",[self getNowDate],[plist getWorkDate]);
            return true;
        }
        return false;
    }
}

-(void)autoUploadFTP:(NSString*) strPath
{
    @autoreleasepool {
        if (!bUseFTP) {
            return;
        }
        
        [self writeLog:@"call function: autoUploadFTP()"];
        [self writeLog:[NSString stringWithFormat:@"-->ftp file path:%@",strPath]];
        @try {
            if ([self isMidNight]==true) {
                
                //检查文件是否存在
                NSFileManager *fm = [NSFileManager defaultManager];
                if (![self getPathByDeletePrefix:&strPath]) {
                    [self writeLog:[NSString stringWithFormat:@"-->cannot find file! maybe this file backup or not exist."]];
                    return;
                }
                
                //创建backup文件夹，将文件移动到这个文件夹
                NSString* strBackupDir=[[strPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"backup"];
                if ([fm fileExistsAtPath:strBackupDir isDirectory:nil]==NO) {
                    [fm createDirectoryAtPath:strBackupDir
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:nil];
                }
                
                //将文件移动到backup文件夹
                NSString* strBackupPath=[strBackupDir stringByAppendingPathComponent:[strPath lastPathComponent]];
                if ([fm moveItemAtPath:strPath toPath:strBackupPath error:nil]) {
                    
                    //文件被移动后，将startline设置为0，将LastDate设置为当前系统的时间
                    @autoreleasepool {
                        AnalyzeData* an=[[AnalyzeData alloc]init:self];
                        [an saveStartLine:strPartNo Line:0];
                    }
    
                    //保存日期到配置config.plist
                    @autoreleasepool {
                        UsePlist* plist=[[UsePlist alloc]initForSys:self];
                        [plist saveWorkDate];
                    }
                   
                    //上传文件到FTP
                    [self uploadFtpFile:strBackupPath];
                    
                    //修改文件名，在其后增加时间
                    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"_yyyyMMddHHmmss"];
                    
                    NSString* file=[strPath lastPathComponent];
                    NSString* newfile=[[[file stringByDeletingPathExtension]
                                        stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]]
                                       stringByAppendingString:[NSString stringWithFormat:@".%@",[file pathExtension]]];
                    
                    NSString* fileBakName=[strBackupDir stringByAppendingPathComponent:newfile];
                    [fm moveItemAtPath:strBackupPath toPath:fileBakName error:nil];
                }
            }
        }
        @catch (NSException *exception) {
            [self writeLog:@"-->upload file to ftp failed"];
            [self showRunState:2 State:0];
        }
        @finally {
            
        }
    }
}

-(void)getFileAttr:(NSString*) strPath;
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *dic= [fm attributesOfItemAtPath:strPath error:nil];
    for (NSString *key in[dic keyEnumerator]) {
        NSLog(@"====== %@=%@\n",key,[dic valueForKey:key]);
    }
}

-(void)createDirectoryUnderAppDirectory:(NSString*) strDir
{
    @autoreleasepool {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *fp01=[[[[NSBundle mainBundle] bundlePath] stringByDeletingPathExtension] stringByDeletingLastPathComponent];
        NSString *fp02=[fp01 stringByAppendingPathComponent:strDir];
        if ([fm fileExistsAtPath:fp02 isDirectory:nil]==NO) {
            [fm createDirectoryAtPath:fp02 withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

-(NSString*)getReadMePath
{
    NSString *fp01=[[[[NSBundle mainBundle] bundlePath] stringByDeletingPathExtension] stringByDeletingLastPathComponent];
    return [fp01 stringByAppendingPathComponent:@"README"];
}

-(NSString*)getReadMeContent
{
    NSString* strTxt;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString *fp02=[self getReadMePath];
    if ([fm fileExistsAtPath:fp02]==NO) {
        strTxt=@"sorry,can not find read me file!";
    }
    else{
        strTxt=[NSString stringWithContentsOfFile:fp02 encoding:NSUTF8StringEncoding error:nil];
    }
    return strTxt;
}

-(bool)checkDBConnect
{
    [self writeLog:@"call function: checkDBConnect()"];
    bool res=false;
    @autoreleasepool {
        @try {
            @autoreleasepool {
                MysqlDB* db=[[MysqlDB alloc]init];
                if ([db connect:strDBIP
                           User:strDBID
                       Password:strDBPWD
                             DB:strDBName]==true) {
                    res=true;
                }
                [db close];
            }
        }
        @catch (NSException *exception) {
            [self writeLog:@"-->FTP connect failed!"];
            [self showRunState:1 State:0];
        }
        @finally {
            
        }

    }
    [self showRunState:1 State:res==true ? 1: 0];
    return res;
}

-(bool)checkFTPConnect
{
    if (!bUseFTP) {
        return false;
    }

    [self writeLog:@"call function: checkFTPConnect()"];
    @try {
        @autoreleasepool {
            FTPManager* ftpManager = [[FTPManager alloc] init];
            FMServer* svr = [FMServer serverWithDestination:strFTPIP
                                                   username:strFTPID
                                                   password:strFTPPWD];
            svr.port = [strFTPPort intValue];
            BOOL res=[ftpManager checkLogin:svr];
            if (res==TRUE) {
                return true;
            }
        }
    }
    @catch (NSException *exception) {
        [self writeLog:@"-->connect FTP server failed!"];
    }
    @finally {
        
    }
    return false;
}

-(bool)checkBarcode:(NSString*) strBar BarFormat:(NSString*) strFMT
{
    bool res=true;
    [self writeLog:@"call function: checkBarcode()"];
    if ([strBar length]==[strFMT length]) {
        NSArray *arrBar = [strBar convertToArray];
        NSArray *arrFMT = [strFMT convertToArray];
        for (int i=0;i<[arrFMT count];i++) {
            for (int j=0;j<[arrBar count];j++) {
                if ([arrFMT[i] isEqualToString:@"*"]==false) {
                    if ([arrFMT[i] isEqualToString:arrBar[i]]==NO) {
                        res=false;
                    }
                }
            }
        }
    }
    else
    {
        res=false;
    }
    [self showRunState:3 State:res==true? 1: 0];
    return res;
}

-(NSString*)getDateTime:(NSString*)strDateTime isDate:(bool)useDate DateTable:(_DATATABLE)table
{
    NSString* strVal=nil;
    NSArray* arr1=nil;
    @autoreleasepool {
        @try {
            //ALS:08/15/2015 23:17:31
            //Prox:2015-04-16 11:19:37
            
            if (useDate) {
                switch (table) {
                    case MYSQL_ALS_ICT_DATA:
                        arr1=[strDateTime componentsSeparatedByString:@"//"];
                        strVal=[NSString stringWithFormat:@"%@%@%@",arr1[2],arr1[0],arr1[1]];
                        break;
                    case MYSQL_Prox_FLUKE_DATA:
                        strVal=[strDateTime stringByReplacingOccurrencesOfString:@"-" withString:@""];
                        break;
                    default:
                        break;
                }
            }
            else
            {
                strVal=[strDateTime stringByReplacingOccurrencesOfString:@":" withString:@""];
            }
        }
        @catch (NSException *exception) {
            NSDateFormatter* date1=[[NSDateFormatter alloc] init];
            [date1 setDateFormat:@"yyyyMMdd"];
            strVal=[date1 stringFromDate:[NSDate date]];
        }
        @finally {
            
        }
    }
    return strVal;
}

-(NSString*)getFTPPath
{
    //FTP Dir:FSAPH70/20151209/bubble/proxFlexOQC_1.0.0f2.csv
    //create directory.
    NSString* Path = [@"" stringByStandardizingPath];
    Path=[Path stringByAppendingPathComponent:strPartNo];
    NSDateFormatter *dateF=[[NSDateFormatter alloc] init];
    [dateF setDateFormat:@"yyyyMMdd"];
    Path=[Path stringByAppendingPathComponent:[dateF stringFromDate:[NSDate date]]];
    Path=[Path stringByAppendingPathComponent:[self getHostName]];
    return [Path stringByAppendingPathComponent:[strFilePath lastPathComponent]];
}

-(bool)isFileExist:(NSString*)strPath
{
    if (strPath==nil) {
        return false;
    }
    NSRange rang=[strPath rangeOfString:@"file:"];
    if (rang.location==0) {
        strPath=[strPath substringFromIndex:rang.location+5];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[strPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "] isDirectory:false]==NO){
        return false;
    }
    return true;
}

-(NSString*)getFileType
{
    int type=[self getDataFileType];
    switch (type) {
        case ALS_J127:
        case ALS_N69:
        case ALS_X109:
        case ALS_X137:
            return @"Hi,ALS";
            break;
        case Prox_N56:
        case Prox_N66:
        case Prox_N71:
            return @"Hi,Prox";
            break;
        case Mic_D10:
        case Mic_X35:
            return @"Hi,Mic";
            break;
            
        default:
            break;
    }
    return nil;
}

-(int)getFactoryType
{
    int res=0;
    if (strFactory) {
        if ([strFactory isEqualToString:@"SG"]) {
            res=1;
        }else if ([strFactory isEqualToString:@"XFY"])
        {
            res=2;
        }else if ([strFactory isEqualToString:@"QHD"]) {
            res=3;
        }
    }
    return res;
}

-(NSString*)getLocalIP
{
    //1.
    //NSHost* myhost =[NSHost currentHost];
    //NSArray *ips=[myhost addresses];
    //NSString* adip=ips[1];
    
    //2.
    InitAddresses();
    GetIPAddresses();
    if (ip_names[1] ==nil && ip_names[1] =='\0') {
        FreeAddresses();
        return nil;
    }
    NSString* adip=[NSString stringWithUTF8String:ip_names[1]];
    [self writeLog:[NSString stringWithFormat:@"local host IP:%@",adip]];
    FreeAddresses();
    return adip;
}

-(_LOCALDATATYPE)getDataFileType
{
    if (strFileType) {
        if ([strFileType compare:@"/temp/ALS/X109" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            return ALS_X109;
        }else if ([strFileType compare:@"/temp/ALS/X137" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            return ALS_X137;
        }else if ([strFileType compare:@"/temp/ALS/N69" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            return ALS_N69;
        }else if ([strFileType compare:@"/temp/Prox/N56ProxFlex" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            return Prox_N56;
        }else if ([strFileType compare:@"/temp/Prox/N66ProxFlex" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            return Prox_N66;
        }else if ([strFileType compare:@"/temp/Prox/N71ProxFlex" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            return Prox_N71;
        }else if ([strFileType compare:@"/temp/ALS/J127" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            return ALS_J127;
        }else if ([strFileType compare:@"/temp/MIC/X35" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            return Mic_X35;
        }else if ([strFileType compare:@"/temp/MIC/D10" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            return Mic_D10;
        }
    }
    return DATA_TYPE_NONE;
}

-(void)showRunState:(bool)runOK
{
    //正常：NSStatusNone
    //活动：NSStatusAvailable
    
    NSString* imgName=nil;
    if (runOK) {
        imgName=@"NSStatusAvailable";
    }
    else{
        imgName=@"NSStatusNone";
    }
    static int pos=0;
    pos++;
    [imgLeft setImage:[NSImage imageNamed:@"NSStatusNone"]];
    [imgMiddle setImage:[NSImage imageNamed:@"NSStatusNone"]];
    [imgRight setImage:[NSImage imageNamed:@"NSStatusNone"]];
    switch (pos % 3) {
        case 0: [imgLeft setImage:[NSImage imageNamed:imgName]];  break;
        case 1: [imgMiddle setImage:[NSImage imageNamed:imgName]];  break;
        case 2: [imgRight setImage:[NSImage imageNamed:imgName]];  break;
        default:
            break;
    }
    
    if (pos==3) {
        pos=0;
    }
}

-(void)showRunState:(int)tag State:(int)state
{
    //正确：NSMenuOnStateTemplate
    //错误：NSStopProgressTemplate
    //未知：NSMenuMixedStateTemplate
    
    NSString* imgName=nil;
    switch (state) {
        case 0:  imgName=@"NSStopProgressTemplate";     break;
        case 1:  imgName=@"NSMenuOnStateTemplate";      break;
        default:
            break;
    }
    
    switch (tag) {
        case 1:   [imgDBLink setImage:[NSImage imageNamed:imgName]];                                                            break;
        case 2:   [imgFTPLink setImage:[NSImage imageNamed:bUseFTP==true ? imgName: @"NSMenuMixedStateTemplate"]];              break;
        case 3:   [imgBarChk setImage:[NSImage imageNamed:bUseCheckBarcode==true? imgName: @"NSMenuMixedStateTemplate"]];       break;
        case 4:   [txtLogType setStringValue:strFileType];                                                                      break;
        default:
            break;
    }
}

-(void)showHourProduct
{
    /*
     按小时计算产能思路：
     1）开始上传的时候会有批量的重新上传的情况，所以开始测试的时候不能作为计时的开始t0
     2）当测试完10pcs后开始计时(countHourProducts==10,t0=当前时刻)
     3）当前时刻－t0==1sec，将当前时刻赋值给t0，重新来计算时间和累积产量，
     因为不这样做，在休息和就餐时段的统计会失真，如果按照作息来做产量统计，逻辑麻烦
     */
    if (countHourProducts==10) {
        startProduct=[NSDate date];
    }
    if (startProduct) {
        NSTimeInterval startInt=[startProduct timeIntervalSince1970];
        NSDate* now=[NSDate date];
        NSTimeInterval nowInt=[now timeIntervalSince1970];
        NSTimeInterval ti=nowInt-startInt;
        if (ti>60) {
            [txtHourProduct setStringValue:[NSString stringWithFormat:@"产量(每60s):%1.0f",hourProducts]];
            startProduct=[NSDate date];
            hourProducts=0;
        }
    }
    
    if (countHourProducts>100) {
        countHourProducts=100;
    }
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

-(void)writeLog:(NSString*)strMsg
{
    @autoreleasepool {
        UserLog* log=[[UserLog alloc]init:self];
        [log writeLog:strMsg];
    }
}

-(bool)getPathByDeletePrefix:(NSString**)strPath
{
   @autoreleasepool {
        AnalyzeData* an=[[AnalyzeData alloc]init:self];
        return [an getPathByDeletePrefix:strPath];
   }
}

@end
