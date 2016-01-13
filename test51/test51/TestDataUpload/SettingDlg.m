//
//  SettingDlg.m
//  TestDataUpload
//
//  Created by bubble on 11/10/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#import "SettingDlg.h"

//
@interface TabViewDelegate ()

@end
@implementation TabViewDelegate


-(void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [txtMaxLine setEnabled:false];
    NSInteger itemIndex = [tabView indexOfTabViewItemWithIdentifier:[tabViewItem identifier]];
    switch (itemIndex) {
        case 3:
            if ([self getTempFileType]==Mic_X35) {
                [txtMaxLine setEnabled:true];
            }
            break;
        default:
            break;
    }
}

-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{

}

-(_LOCALDATATYPE) getTempFileType
{
    NSInteger idx=[cmbDataType indexOfSelectedItem];
    if(idx>-1){
        NSString* strTempType=[cmbDataType itemObjectValueAtIndex:idx];
        if (strTempType) {
            if ([strTempType compare:@"/temp/ALS/X109" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return ALS_X109;
            }else if ([strTempType compare:@"/temp/ALS/X137" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return ALS_X137;
            }else if ([strTempType compare:@"/temp/ALS/N69" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return ALS_N69;
            }else if ([strTempType compare:@"/temp/Prox/N56ProxFlex" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return Prox_N56;
            }else if ([strTempType compare:@"/temp/Prox/N66ProxFlex" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return Prox_N66;
            }else if ([strTempType compare:@"/temp/Prox/N71ProxFlex" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return Prox_N71;
            }else if ([strTempType compare:@"/temp/MIC/X35" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return Mic_X35;
            }else if ([strTempType compare:@"/temp/MIC/D10" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return Mic_D10;
            }else if ([strTempType compare:@"/temp/ALS/J127" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return ALS_J127;
            }
        }
    }
    return DATA_TYPE_NONE;
}

@end




//
@interface SettingDlg ()

@end

//
@implementation TableData

@synthesize appID;
@synthesize appName;


@end


//
@implementation SettingDlg

@synthesize strPartNum;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    //
    [self addComboxItems];
    [cmbDataType setEditable:FALSE];
    
#ifdef TARGET_OS_X_10_9
    [btnSaveSetting highlight:true];
    [btnTestDatabase highlight:true];
    [btnFTPTest highlight:true];
#else
    [btnSaveSetting setHighlighted:true];
    [btnTestDatabase setHighlighted:true];
    [btnFTPTest setHighlighted:true];
#endif
    
    //
    [mtFactoryYade setHidden:true];
    
    _lock = [[NSLock alloc] init];
    
    //
    //[self initTableView];
    [self initTableView1];
    [self readPlist];
    [self createTempConfig];
}

-(IBAction)close:(id)sender
{
    //
    if (sender==btnSaveSetting) {
        //check filetype and actual file.
        if ([self checkFileTypeAndFileContent:[self getTempFileType]]==false) {
#ifdef TARGET_OS_X_10_9
            [btnSaveSetting highlight:true];
            [btnTestDatabase highlight:true];
            [btnFTPTest highlight:true];
#else
            [btnSaveSetting setHighlighted:true];
            [btnTestDatabase setHighlighted:true];
            [btnFTPTest setHighlighted:true];
#endif
            return;
        }
        
        [self writePlist];
    }
    
    //
    [NSApp stopModal];
    [self close];
}

//modal dialog close.
- (BOOL)windowShouldClose:(id)sender
{
    [NSApp stopModalWithCode:1];
    return TRUE;
}

-(void) testDBConnect
{
    while (true) {
        @autoreleasepool {
            //mysql
            MysqlDB* db=[[MysqlDB alloc]init];
            if ([db connect:[txtDatabaseIP stringValue]
                       User:[txtDatabaseID stringValue]
                   Password:[txtDatabasePWD stringValue]
                         DB:[txtDatabaseDB stringValue]]==true) {
                [txtConnectState setStringValue:@"Connect successed!"];
                [txtConnectState setTextColor:[NSColor blueColor]];
            }
            else
            {
                [txtConnectState setStringValue:@"Connect failed!"];
                [txtConnectState setTextColor:[NSColor redColor]];
            }
            [db close];
            [NSThread exit];
            DBThread=nil;
            break;
        }
    }
}

-(void) testFTPConnect
{
    while (true) {
        @autoreleasepool {
            @try {
                FTPManager* ftpManager = [[FTPManager alloc] init];
                FMServer* svr = [FMServer serverWithDestination:[txtFTPIP stringValue]
                                                       username:[txtFTPID stringValue]
                                                       password:[txtFTPPWD stringValue]];
                svr.port = [[txtFTPPort stringValue] intValue];
                
                if ([ftpManager contentsOfServer:svr]) {
                    [txtFTPConnectState setStringValue:@"Connect FTP successed!"];
                    [txtFTPConnectState setTextColor:[NSColor blueColor]];
                }
                else
                {
                    [txtFTPConnectState setStringValue:@"Connect FTP failed!"];
                    [txtFTPConnectState setTextColor:[NSColor redColor]];
                }
                [ftpManager abort];
                [NSThread exit];
                FTPThread=nil;
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            break;
        }
    }
}

-(IBAction)testDB:(id)sender
{
    [txtConnectState setStringValue:@"Unkown connection state."];
    [txtConnectState setTextColor:[NSColor redColor]];
    if (!DBThread || ![DBThread isExecuting]) {
        DBThread = [[NSThread alloc] initWithTarget:self
                                           selector:@selector(testDBConnect)
                                             object:nil];
        [DBThread start];
    }
}

-(IBAction)testFTP:(id)sender
{
    [txtFTPConnectState setStringValue:@"Unkown connection state."];
    [txtFTPConnectState setTextColor:[NSColor redColor]];
    if (!FTPThread || ![FTPThread isExecuting]) {
        FTPThread = [[NSThread alloc] initWithTarget:self
                                            selector:@selector(testFTPConnect)
                                              object:nil];
        [FTPThread start];
    }
}

-(void)showAlertMsg:(NSString*)msg
{
    @autoreleasepool {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"From TestdataUpload Says:"];
        [alert setInformativeText:msg];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setHelpAnchor:@"ddd"];
        [alert runModal];
    }
}

-(IBAction)testFTPUpload:(id)sender
{
    NSString* filepath=[txtFTPFilePath stringValue];
    if ([self.strPartNum compare:@"" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
        [self showAlertMsg:@"input partnum first,pls!"];
        return;
    }
    if (filepath==nil) {
        return;
    }
    else
    {
        NSRange rang=[filepath rangeOfString:@"file:"];
        if (rang.location==0) {
            filepath=[filepath substringFromIndex:rang.location+5];
        }
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:filepath isDirectory:false]==NO){
            return;
        }
    }
    
    //
    [txtFTPConnectState setStringValue:@"Unkown connection state."];
    @autoreleasepool {
        FTPManager* ftpManager = [[FTPManager alloc] init];
        FMServer* svr = [FMServer serverWithDestination:[txtFTPIP stringValue]
                                               username:[txtFTPID stringValue]
                                               password:[txtFTPPWD stringValue]];
        svr.port = [[txtFTPPort stringValue] intValue];
        
        //create directory.
        //ftp://192.168.101.246/ALS/fsapa29/20151118/hostname/FSAPA29 20151120.csv
        NSString* path=@"";
        NSString* strPath = [path stringByStandardizingPath];
        strPath=[strPath stringByAppendingPathComponent:[txtFTPDir stringValue]];
        strPath=[strPath stringByAppendingPathComponent:self.strPartNum];
        NSDateFormatter *dateF=[[NSDateFormatter alloc] init];
        [dateF setDateFormat:@"yyyyMMdd"];
        strPath=[strPath stringByAppendingPathComponent:[dateF stringFromDate:[NSDate date]]];
        strPath=[strPath stringByAppendingPathComponent:[self getHostName]];
        //
        BOOL crtBOOL=[ftpManager createNewFolders:strPath atServer:svr];
        if (!crtBOOL) {
            NSLog(@"create directory err!");
        }
        [ftpManager abort];
        
        //upload file.
        FMServer* svr1 = [FMServer serverWithDestination:[[txtFTPIP stringValue] stringByAppendingPathComponent:strPath]
                                               username:[txtFTPID stringValue]
                                                password:[txtFTPPWD stringValue]];
        BOOL res=[ftpManager uploadFile:[NSURL URLWithString:filepath] toServer:svr1];
        if (res) {
            [txtFTPConnectState setStringValue:@"Upload file successed!"];
            [txtFTPConnectState setTextColor:[NSColor blueColor]];
        }
        else
        {
            [txtFTPConnectState setStringValue:@"Upload file failed!"];
            [txtFTPConnectState setTextColor:[NSColor redColor]];
        }
        [ftpManager abort];
    }
}

-(NSString*) getFilePath:(NSString*)pathURL
{
    NSRange rang=[pathURL rangeOfString:@"file:"];
    if (rang.location==0) {
        pathURL=[pathURL substringFromIndex:rang.location+5];
    }
    return pathURL;
}

-(NSString*) getHostName
{
    //#include <SystemConfiguration/SystemConfiguration.h>
    // Returns NULL/nil if no computer name set, or error occurred. OSX 10.1+
    NSString *computerName = (NSString *)CFBridgingRelease(SCDynamicStoreCopyComputerName(NULL, NULL)) ;
    
    // Returns NULL/nil if no local hostname set, or error occurred. OSX 10.2+
    //NSString *localHostname = (NSString *)CFBridgingRelease(SCDynamicStoreCopyLocalHostName(NULL)) ;
    return computerName;
}

-(IBAction)browseFile:(id)sender
{
    /*
     if (sender==btnBrowse) {
     NSOpenPanel* openDlg = [NSOpenPanel openPanel];
     [openDlg setCanChooseFiles:YES];
     [openDlg setCanChooseDirectories:YES];
     [openDlg setPrompt:@"Select"];
     
     if ( [openDlg runModal] == NSModalResponseOK )
     {
     NSArray* files = [openDlg URLs];
     for( int i = 0; i < [files count]; i++ )
     {
     NSString* fileName = [files objectAtIndex:i];
     [txtDataDir setStringValue:fileName];
     }
     }
     }
     */
    
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setResolvesAliases:YES];
    [openPanel setPrompt:@"Select"];
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        [openPanel close];
        if (result == NSFileHandlingPanelOKButton) {
            NSString* strFile=[[openPanel URLs] objectAtIndex:0];
            [txtFilePath setStringValue:strFile];
        }
    }];
}

-(IBAction)browseFTPFile:(id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setResolvesAliases:YES];
    [openPanel setPrompt:@"Select"];
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        [openPanel close];
        if (result == NSFileHandlingPanelOKButton) {
            NSString* strFile=[[openPanel URLs] objectAtIndex:0];
            [txtFTPFilePath setStringValue:strFile];
        }
    }];
}

-(NSString*)getPathByDeletePrefix:(NSString*)strPath
{
    //删除文件路径前的file:
    NSRange rang=[strPath rangeOfString:@"file:"];
    if (rang.location==0) {
        strPath=[strPath substringFromIndex:rang.location+5];
    }
    return strPath;
}

-(bool)getPathByDeletePrefix1:(NSString**)strPath
{
    //传引用
    NSRange rang=[*strPath rangeOfString:@"file:"];
    if (rang.location==0) {
        *strPath=[*strPath substringFromIndex:rang.location+5];
    }

    *strPath=[*strPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:*strPath]==FALSE){
        return false;
    }

//    if (access([*strPath UTF8String], 0)!=0) {
//        return false;
//    }
    
    return true;
}

-(bool) checkFileTypeAndFileContent
{    
    @try {
        NSString* strPath=[self getPathByDeletePrefix:[txtFilePath stringValue]];
        //check file format
        if ([[[[txtFilePath stringValue] pathExtension] uppercaseString] isEqualToString:@"CSV"]==false &&
            [[[[txtFilePath stringValue] pathExtension] uppercaseString] isEqualToString:@"TXT"]==false) {
            [self showAlertMsg:@"you should select .csv/.txt format file!"];
            return false;
        }
        
        if ([self getPathByDeletePrefix1:&strPath]==false) {
            [self showAlertMsg:@"the actual file is not exist!"];
            return false;
        }
        
        //check file content
        NSString* strTempType=[cmbDataType itemObjectValueAtIndex:[cmbDataType indexOfSelectedItem]];
        NSString* strTempFileName=[self getTempFileName:strTempType];
        NSString* strTempFilePath=[[[self getRoot] stringByAppendingPathComponent:strTempType] stringByAppendingPathComponent:strTempFileName];
        NSString* strTempFileBlock=[self getBlockFromFile2:strTempFilePath];
        NSString* strFileBlock=[self getBlockFromFile2:strPath Size:(int)[strTempFileBlock length]];
        NSRange rang2=[strFileBlock rangeOfString:strTempFileBlock];
        if (rang2.length==0) {
            [self showAlertMsg:@"the actual file is not match file type!"];
            return false;
        }
        
        return true;
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return false;
}

-(bool) checkFileTypeAndFileContent:(_LOCALDATATYPE)type
{
    if (type==DATA_TYPE_NONE) {
        [self showAlertMsg:@"some errs in filelist.plist!"];
        return false;
    }
    
    @try {
        NSString* strPath=[self getPathByDeletePrefix:[txtFilePath stringValue]];
        //check file format
        if ([[[[txtFilePath stringValue] pathExtension] uppercaseString] isEqualToString:@"CSV"]==false &&
            [[[[txtFilePath stringValue] pathExtension] uppercaseString] isEqualToString:@"TXT"]==false) {
            [self showAlertMsg:@"you should select .csv/.txt format file!"];
            return false;
        }
        
        if ([self getPathByDeletePrefix1:&strPath]==false) {
            [self showAlertMsg:@"the actual file is not exist!"];
            return false;
        }
        
        if (type==DATA_TYPE_NONE) {
            [self showAlertMsg:@"pls select file type!"];
            return false;
        }
        
        //check file content
        NSString* strTempFileBlock=nil;
        switch (type) {
            case ALS_X109:
            case ALS_X137:
                strTempFileBlock=[self getBlockFromFile2:[self getTempFilePath]];
                NSRange rang2=[strTempFileBlock rangeOfString:@"FAILURE_MSG"];
                strTempFileBlock=[strTempFileBlock substringToIndex:rang2.location];
                break;
            case ALS_N69:
            case Prox_N56:
            case Prox_N66:
            case Prox_N71:
            case ALS_J127:
            case Mic_D10:
                strTempFileBlock=[self getBlockFromFile2:[self getTempFilePath]];
                break;
            case Mic_X35:
                return [self checkFileTypeAndFileContentForMic:strPath];
            default:
                break;
        }
        
        NSString* strFileBlock=[self getBlockFromFile2:strPath Size:(int)[strTempFileBlock length]];
        NSRange rang2=[strFileBlock rangeOfString:strTempFileBlock];
        if (rang2.length==0) {
            [self showAlertMsg:@"the actual file is not match file type!"];
            return false;
        }
        
        return true;
    }
    @catch (NSException *exception) {
        [self showAlertMsg:@"the actual file is not match file type!"];
    }
    @finally {
        
    }
    
    return false;
}

-(bool) checkFileTypeAndFileContentForMic:(NSString*)strPath
{
    NSString* strFileBlock=[self getBlockFromFile2:strPath];
    NSRange rang1=[strFileBlock rangeOfString:@"dB"];
    NSRange rang2=[strFileBlock rangeOfString:@"Limits"];
    if (rang1.length==0 && rang2.length==0) {
        [self showAlertMsg:@"you selected file may not MIC test builds!"];
        return false;
    }
    return true;
}

-(void) writePlist
{
    [self writeLog:@"call fucntion writePlist()"];
    
    //save data to plist file.
    @autoreleasepool {
        @try {
            NSDictionary *dict=nil;
            NSDictionary* db=nil;
            NSDictionary* ftp=nil;
            NSDictionary* data=nil;
            NSDictionary* pro=nil;
            
            NSString *fp02=[self getConfigPath];
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:fp02 isDirectory:false]==NO){
                dict =[NSMutableDictionary new];
                db =[NSMutableDictionary new];
                ftp =[NSMutableDictionary new];
                data =[NSMutableDictionary new];
                pro =[NSMutableDictionary new];
            }
            else{
                dict=[NSDictionary dictionaryWithContentsOfFile:fp02];
                db =[dict objectForKey:@"Database"];
                ftp =[dict objectForKey:@"FTP"];
                data =[dict objectForKey:@"Data"];
                
                //beacuse "Process" items can be deleted and added,so this section should create every time.
                //pro =[dict objectForKey:@"Process"];
                pro =[NSMutableDictionary new];
            }
            
            [dict setValue:[NSNumber numberWithInt:[btnCheckRunStart state]==NSOnState?1:0] forKey:@"UseRunStart"];
            [dict setValue:[NSNumber numberWithInt:[btnCheckBarcode state]==NSOnState?1:0] forKey:@"UseCheckBarcode"];
            [dict setValue:[NSNumber numberWithInt:[btnCheckUploadFTP state]==NSOnState?1:0] forKey:@"UseFTP"];
            [dict setValue:[NSNumber numberWithInt:[btnCheckAgainstCheat state]==NSOnState?1:0] forKey:@"UseAgainstCheat"];
            [dict setValue:[NSNumber numberWithInt:[btnCheckRenameFiles state]==NSOnState?1:0] forKey:@"UseRenameFiles"];
            
            [db setValue:[txtDatabaseIP stringValue] forKey:@"IP"];
            [db setValue:[txtDatabaseDB stringValue] forKey:@"DB"];
            [db setValue:[txtDatabaseID stringValue] forKey:@"ID"];
            [db setValue:[txtDatabasePWD stringValue] forKey:@"PWD"];
            [ftp setValue:[txtFTPIP stringValue] forKey:@"IP"];
            [ftp setValue:[txtFTPPort stringValue] forKey:@"Port"];
            [ftp setValue:[txtFTPID stringValue] forKey:@"ID"];
            [ftp setValue:[txtFTPPWD stringValue] forKey:@"PWD"];
            [ftp setValue:[txtFTPDir stringValue] forKey:@"Dir"];
            [ftp setValue:[txtFTPFilePath stringValue] forKey:@"Path"];
            [data setValue:[cmbDataType itemObjectValueAtIndex:[cmbDataType indexOfSelectedItem]] forKey:@"Type"];
            [data setValue:[txtFilePath stringValue] forKey:@"Path"];
            
            for (int i=0; i<[array count]; i++) {
                TableData *data = [[TableData alloc]init];
                data=array[i];
                NSLog(@"%@",data.appName);
                if ([data.appName isEqualTo:@""]==false) {
                    [pro setValue:data.appName forKey:[NSString stringWithFormat:@"%d",i]];
                }
            }
            
            [dict setValue:db forKey:@"Database"];
            [dict setValue:ftp forKey:@"FTP"];
            [dict setValue:data forKey:@"Data"];
            [dict setValue:pro forKey:@"Process"];
            [dict setValue:[txtPollTime stringValue] forKey:@"PollTime"];
            [dict setValue:[txtStartLine stringValue] forKey:@"StartLine"];
            [self saveStartLine:strPartNum Line:[[txtStartLine stringValue]doubleValue]];
            if ([self getTempFileType]==Mic_X35) {
                [dict setValue:[txtMaxLine stringValue] forKey:@"MaxLine"];
                [self saveMaxLine:strPartNum Line:[txtMaxLine stringValue]];
            }
            
            //NSString* strFac=[mtFactoryYade selectedTag]==1 ? @"SG" : @"XFY";
            //[dict setValue:strFac forKey:@"FactoryYade"];
            if ([mtFactoryYade selectedTag]==1) {
                [dict setValue:@"SG" forKey:@"FactoryYade"];
            }else if ([mtFactoryYade selectedTag]==2)
            {
                [dict setValue:@"XFY" forKey:@"FactoryYade"];
            }else if ([mtFactoryYade selectedTag]==3)
            {
                [dict setValue:@"QHD" forKey:@"FactoryYade"];
            }
            
            //
            [dict writeToFile:fp02 atomically:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            
        }
    }
}

-(void) readPlist
{
    [self writeLog:@"call fucntion readPlist()"];
    @try {
        NSDictionary *dict=nil;
        NSString *fp02=[self getConfigPath];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:fp02 isDirectory:false]==NO) {
            return;
        }
        
        //
        dict=[NSDictionary dictionaryWithContentsOfFile:fp02];
        
        [btnCheckRunStart setState:[[dict objectForKey:@"UseRunStart"]intValue]];
        [btnCheckBarcode setState:[[dict objectForKey:@"UseCheckBarcode"]intValue]];
        [btnCheckUploadFTP setState:[[dict objectForKey:@"UseFTP"]intValue]];
        [btnCheckAgainstCheat setState:[[dict objectForKey:@"UseAgainstCheat"]intValue]];
        [btnCheckRenameFiles setState:[[dict objectForKey:@"UseRenameFiles"]intValue]];
        
        NSDictionary * db =[dict objectForKey:@"Database"];
        NSDictionary * ftp =[dict objectForKey:@"FTP"];
        NSDictionary * data =[dict objectForKey:@"Data"];
        
        [txtDatabaseIP setStringValue: [db objectForKey:@"IP"]];
        [txtDatabaseDB setStringValue: [db objectForKey:@"DB"]];
        [txtDatabaseID setStringValue: [db objectForKey:@"ID"]];
        [txtDatabasePWD setStringValue: [db objectForKey:@"PWD"]];
        
        [txtFTPIP setStringValue: [ftp objectForKey:@"IP"]];
        [txtFTPPort setStringValue: [ftp objectForKey:@"Port"]];
        [txtFTPID setStringValue: [ftp objectForKey:@"ID"]];
        [txtFTPPWD setStringValue: [ftp objectForKey:@"PWD"]];
        [txtFTPDir setStringValue: [ftp objectForKey:@"Dir"]];
        [txtFTPFilePath setStringValue: [ftp objectForKey:@"Path"]];
        [cmbDataType selectItemWithObjectValue:[data objectForKey:@"Type"]];
        [txtFilePath setStringValue: [data objectForKey:@"Path"]];
        [txtPollTime setStringValue: [dict objectForKey:@"PollTime"]];
        [txtStartLine setStringValue: [dict objectForKey:@"StartLine"]];
        [txtMaxLine setStringValue: [self getMaxLine:strPartNum]];

        //NSInteger nSel=[[dict objectForKey:@"FactoryYade"] isEqualToString:@"SG"]==true ? 0 : 1;
        if ([[dict objectForKey:@"FactoryYade"] isEqualToString:@"SG"]) {
            [mtFactoryYade setState:1 atRow:0 column:0];
        }else if ([[dict objectForKey:@"FactoryYade"] isEqualToString:@"XFY"])
        {
            [mtFactoryYade setState:1 atRow:1 column:0];
        }else if ([[dict objectForKey:@"FactoryYade"] isEqualToString:@"QHD"]) {
            [mtFactoryYade setState:1 atRow:2 column:0];
        }
        
        //
        [array removeAllObjects];
        NSDictionary * pro =[dict objectForKey:@"Process"];
        for (int i=0; i<[pro count]; i++) {
            TableData *data = [[TableData alloc]init];
            [data setAppID:[NSString stringWithFormat:@"%d",i]];
            [data setAppName:[pro objectForKey:[NSString stringWithFormat:@"%d",i]]];
            [array addObject:data];
        }
        [tableView reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        
    }
}

-(void) initTableView
{
    //
    NSArray* arrCols=[tableView tableColumns];
    if ([arrCols count]==2) {
        [arrCols[0] setTitle:@"ID"];
        [arrCols[1] setTitle:@"Process Name"];
    }

    //
    array = [[NSMutableArray alloc]init];
    for (int i = 0;i < 10;i ++) {
        TableData *data = [[TableData alloc]init];
        [data setAppID:[NSString stringWithFormat:@"%d",i]];
        [data setAppName:@"hello"];
        [array addObject:data];
    }
    [tableView reloadData];
}

-(void) initTableView1
{
    //
    NSTableColumn * column1 = [[NSTableColumn alloc] initWithIdentifier:@"col1"];
    NSTableColumn * column2 = [[NSTableColumn alloc] initWithIdentifier:@"col2"];
    [column1 setWidth:25];
    
#ifdef TARGET_OS_X_10_9
    [column1 setIdentifier:@"ID"];
    [column2 setIdentifier:@"Process Name"];
#else
    [column1 setTitle:@"ID"];
    [column2 setTitle:@"Process Name"];
#endif
    
    //delete all column
    NSTableColumn* col;
    while ((col = [[tableView tableColumns] lastObject])) {
        [tableView removeTableColumn:col];
    }
    [tableView addTableColumn:column1];
    [tableView addTableColumn:column2];

    //
    array = [[NSMutableArray alloc]init];
//    for (int i = 0;i < 10;i ++)
//    {
//        TableData *data = [[TableData alloc]init];
//        [data setAppID:[NSString stringWithFormat:@"%d",i]];
//        [data setAppName:@"hello"];
//        [array addObject:data];
//    }
    
    [tableView reloadData];
  
}

-(void) deleteAllColumns
{
    //1.
    NSTableColumn* col;
    while ((col = [[tableView tableColumns] lastObject])) {
        [tableView removeTableColumn:col];
    }
    
    //2.
//    while([[tableView tableColumns] count] > 0) {
//        [tableView removeTableColumn:[[tableView tableColumns] lastObject]];
//    }
}

//return table rows number.
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [array count];
}

//if dispaly data use 'willDisplayCell' function,
//you may not use this function but you should defined it with nil return value.
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return nil;
}

//dispaly data in table cells.
/*
•	把NSTableView拖放到界面上。
•	把TableView的DataSource指向App Delegate
•	设置TableView 的 ContentMode为Cell Based (1）
 */
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    //method1
    /*
    TableData *data = [array objectAtIndex:row];
    NSString *identifier = [tableColumn title];
    if ([identifier isEqualToString:@"ID"]) {
        NSTextFieldCell *textCell = cell;
        [textCell setTitle:[data appID]];
    }
    else if ([identifier isEqualToString:@"Process Name"]) {
        NSTextFieldCell *textCell = cell;
        [textCell setTitle:[data appName]];
    }
    */
    
    //method2
    TableData *data = [array objectAtIndex:row];
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"col1"]) {
        NSTextFieldCell *textCell = cell;
        [textCell setTitle:[data appID]];
    }
    else if ([identifier isEqualToString:@"col2"]) {
        NSTextFieldCell *textCell = cell;
        [textCell setTitle:[data appName]];
    }
}

-(IBAction)addTableRow:(id)sender
{
    TableData *data = [[TableData alloc]init];
    [data setAppID:[NSString stringWithFormat:@"%ld",[array count]]];
    [data setAppName:@""];
    [array addObject:data];
    [tableView reloadData];
}

-(IBAction)deleteTableRow:(id)sender
{
    NSInteger indx = [tableView selectedRow];
    if(indx<=-1) {
        return;
    }
 
    [array removeObjectAtIndex:indx];
    [tableView reloadData];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [tableView setTarget:self];
    [tableView setDoubleAction:NSSelectorFromString(@"doubleClickInTableView:")];
}

//double click event.
- (void)doubleClickInTableView:(id)sender
{
    NSInteger row = [tableView clickedRow];
    tableRow=row;
    [tableView editColumn:1 row:row withEvent:nil select:YES];
    NSLog(@"Double Clicked.%ld ",row);
}

//end edit on table cells.
- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSDictionary *userInfo = [obj userInfo];
    NSTextView *aView = [userInfo valueForKey:@"NSFieldEditor"];
    NSLog(@"controlTextDidEndEditing %@", [aView string] );
    
    //
    //NSInteger row = [tableView clickedRow];
    NSInteger row = tableRow;
    TableData *data = [[TableData alloc]init];
    [data setAppID:[NSString stringWithFormat:@"%ld",row]];
    [data setAppName:[aView string]];
 
    [array insertObject:data atIndex:row];
    [array removeObjectAtIndex:row+1];
    [tableView reloadData];
}

//if you want to modify items's values but not create,
//you should read from file and change the NSDictionary.
-(void) saveTarget
{
    NSDictionary *dict;
    NSString *fp02=[self getConfigPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:fp02 isDirectory:false]==NO){
        dict =[NSMutableDictionary new];
    }
    else{
        dict=[NSDictionary dictionaryWithContentsOfFile:fp02];
    }
    
    //
    NSDictionary * db =[dict objectForKey:@"Database"];
    [db setValue:@"test1" forKey:@"IP"];
    [dict setValue:db forKey:@"Database"];
    [dict writeToFile:fp02 atomically:YES];
}

-(void)writeLog:(NSString*) strMsg
{
    @try {
        NSDateFormatter* dateFMT1=[[NSDateFormatter alloc] init];
        [dateFMT1 setDateFormat:@"yyyyMMdd"];
        NSString* fPName=[[dateFMT1 stringFromDate:[NSDate date]] stringByAppendingString:@".log"];
        
        //
        NSFileManager* fm = [NSFileManager defaultManager];
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
            if([[dic objectForKey:@"NSFileSize"] doubleValue]>1024*1024*5) {
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

//some error in this function
-(NSString*) getBlockFromFile:(NSString*)path
{
    //
    [self writeLog:@"call fucntion getBlockFromFile()"];
    NSRange rang=[path rangeOfString:@"file:"];
    if (rang.location==0) {
        path=[path substringFromIndex:rang.location+5];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path isDirectory:false]==NO){
        return nil;
    }
    
    //
    [self writeLog:[NSString stringWithFormat:@"-->file path:%@",path]];
    NSString* strLine=@"";
    FILE *wordFile=fopen([path UTF8String], "r");
    for (int i=0;i<15;i++) {
        //c++ include stdio.h
        char wordData[5000]={0};
        fgets(wordData,5000,wordFile); //this method read file line by line
        wordData[strlen(wordData)-1] ='\0';
        strLine=[strLine stringByAppendingString:[NSString stringWithUTF8String:wordData]];
    }
    fclose(wordFile);
    
    return strLine;
}

-(NSString*) getBlockFromFile2:(NSString*)path
{
    NSString* strHead=nil;
    if (path!=nil) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:path]==NO) {
            strHead=nil;
        }
        else{
            if ([self getTempFileType]==ALS_J127) {
                strHead=[NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
            }
            else{
                strHead=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            }
        }
    }
    return strHead;
}

-(NSString*) getBlockFromFile2:(NSString*)path Size:(int)size
{
    @try {
        NSString* strHead=[self getBlockFromFile2:path];
        strHead=[strHead substringToIndex:size];
        return strHead;
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return nil;
}

-(NSString*)getConfigPath
{
    return [self getPathWithRoot:@"config.plist"];
}

-(void) addComboxItems
{
    while([cmbDataType numberOfItems]) {
        [cmbDataType removeItemAtIndex:0];
    }
    
    //file template
    NSArray* arr1=[self getAllTempFileType];
    for (NSString* str1 in arr1) {
        [cmbDataType addItemWithObjectValue:str1];
    }
}

-(NSString*) getPathWithRoot:(NSString*)folder
{
    return[[self getRoot] stringByAppendingPathComponent:folder];
}

-(NSString*) getRoot
{
    return [[[[NSBundle mainBundle] bundlePath] stringByDeletingPathExtension] stringByDeletingLastPathComponent];
}

-(void) createTempConfig
{
    NSDictionary *dict=nil;
    NSString *fp02=[self getPathWithRoot:@"temp"];
    NSString *fp03=[fp02 stringByAppendingPathComponent:@"filelist.plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:fp02 isDirectory:nil]==NO) {
        [fm createDirectoryAtPath:fp02 withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([fm fileExistsAtPath:fp03 isDirectory:false]==NO){
        dict =[NSMutableDictionary new];
        [dict setValue:@"calibration_summary.csv" forKey:@"/temp/ALS1"];
        [dict writeToFile:fp03 atomically:YES];
    }
}

-(NSString*) getTempFileName:(NSString*)fileType
{
    NSDictionary *dict=nil;
    NSString *fp02=[self getPathWithRoot:@"temp"];
    NSString *fp03=[fp02 stringByAppendingPathComponent:@"filelist.plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:fp03 isDirectory:false]==NO) {
        return nil;
    }
    
    dict=[NSDictionary dictionaryWithContentsOfFile:fp03];
    return [dict objectForKey:fileType];
}

-(NSArray*) getAllTempFileType
{
    NSDictionary *dict=nil;
    NSString *fp02=[self getPathWithRoot:@"temp"];
    NSString *fp03=[fp02 stringByAppendingPathComponent:@"filelist.plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:fp03 isDirectory:false]==NO) {
        return nil;
    }
    
    dict=[NSDictionary dictionaryWithContentsOfFile:fp03];
    NSArray* keys=[dict allKeys];
    NSMutableArray* arr1=[[NSMutableArray alloc]init];
    for(NSString * subject in keys)
    {
        [arr1 addObject:subject];
    }
    return arr1;
}

-(NSArray*) getAllTempFileName
{
    NSDictionary *dict=nil;
    NSString *fp02=[self getPathWithRoot:@"temp"];
    NSString *fp03=[fp02 stringByAppendingPathComponent:@"filelist.plist"];
   NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:fp03 isDirectory:false]==NO) {
        return nil;
    }
    
    dict=[NSDictionary dictionaryWithContentsOfFile:fp03];
    NSArray* keys=[dict allKeys];
    NSMutableArray* arr1=[[NSMutableArray alloc]init];
    for(NSString * subject in keys)
    {
        [arr1 addObject:[dict objectForKey:subject]];
    }
    return arr1;
}

-(NSString*) getTempFilePath
{
    NSString* strTempType=[cmbDataType itemObjectValueAtIndex:[cmbDataType indexOfSelectedItem]];
    NSString* strTempFileName=[self getTempFileName:strTempType];
    return [[[self getRoot] stringByAppendingPathComponent:strTempType] stringByAppendingPathComponent:strTempFileName];
}

-(_LOCALDATATYPE) getTempFileType
{
    NSInteger idx=[cmbDataType indexOfSelectedItem];
    if (idx>-1) {
        NSString* strTempType=[cmbDataType itemObjectValueAtIndex:idx];
        if (strTempType) {
            if ([strTempType compare:@"/temp/ALS/X109" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return ALS_X109;
            }else if ([strTempType compare:@"/temp/ALS/X137" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return ALS_X137;
            }else if ([strTempType compare:@"/temp/ALS/N69" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return ALS_N69;
            }else if ([strTempType compare:@"/temp/Prox/N56ProxFlex" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return Prox_N56;
            }else if ([strTempType compare:@"/temp/Prox/N66ProxFlex" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return Prox_N66;
            }else if ([strTempType compare:@"/temp/Prox/N71ProxFlex" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return Prox_N71;
            }else if ([strTempType compare:@"/temp/MIC/X35" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return Mic_X35;
            }else if ([strTempType compare:@"/temp/MIC/D10" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return Mic_D10;
            }else if ([strTempType compare:@"/temp/ALS/J127" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                return ALS_J127;
            }
        }
    }
    return DATA_TYPE_NONE;
}

-(NSString*) getMaxLine:(NSString*)strPart
{
    @autoreleasepool {
        FileLine* fl=[[FileLine alloc]init:@"maxline.setting" LINETYPE:SETTING_MAX_LINE];
        return [NSString stringWithFormat:@"%1.0f",[fl getMaxLine:strPart]];
    }
}

-(double) getStartLine:(NSString*)strID
{
    @autoreleasepool {
        FileLine* fl=[[FileLine alloc]init:@"startline.setting" LINETYPE:SETTING_START_LINE];
        return [fl getStartLine:strID];
    }
}

-(void) saveMaxLine:(NSString*)strPart Line:(NSString*)line
{
    @autoreleasepool {
        FileLine* fl=[[FileLine alloc]init:@"maxline.setting" LINETYPE:SETTING_MAX_LINE];
        [fl saveMaxLine:strPart Line:[line doubleValue]];
    }
}

-(void) saveStartLine:(NSString*)strID Line:(double)line
{
    @autoreleasepool {
        FileLine* fl=[[FileLine alloc]init:@"startline.setting" LINETYPE:SETTING_START_LINE];
        [fl saveStartLine:strID Line:line];
    }
}



@end
