//
//  SettingDlg.h
//  TestDataUpload
//
//  Created by bubble on 11/10/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MySQLHelper.h"
#import "FTPManager.h"
#include <SystemConfiguration/SystemConfiguration.h>
#import "MDBufferedInputStream.h"
#import "UserDef.h"
#import "FileLine.h"


@interface SettingDlg : NSWindowController
{
    IBOutlet NSButton *btnCheckRunStart;
    IBOutlet NSButton *btnCheckBarcode;
    IBOutlet NSButton *btnCheckUploadFTP;
    IBOutlet NSButton *btnCheckAgainstCheat;
    IBOutlet NSButton *btnCheckRenameFiles;
    
    IBOutlet NSButton *btnTestDatabase;
    IBOutlet NSButton *btnFTPTest;
    IBOutlet NSButton *btnBrowse;
    IBOutlet NSButton *btnBrowseFTP;
    IBOutlet NSButton *btnFTPUploadTest;
    IBOutlet NSButton* btnSaveSetting;
    IBOutlet NSButton* btnCloseSetting;
    
    IBOutlet NSTextField *txtDatabaseIP;
    IBOutlet NSTextField *txtDatabaseDB;
    IBOutlet NSTextField *txtDatabaseID;
    IBOutlet NSTextField *txtDatabasePWD;
    IBOutlet NSTextField *txtConnectState;
    IBOutlet NSTextField *txtFilePath;
    IBOutlet NSTextField *txtPollTime;
    IBOutlet NSTextField *txtStartLine;
    IBOutlet NSTextField *txtMaxLine;
    IBOutlet NSTextField *txtCopyTime;
    IBOutlet NSTextField *txtFTPIP;
    IBOutlet NSTextField *txtFTPPort;
    IBOutlet NSTextField *txtFTPID;
    IBOutlet NSTextField *txtFTPPWD;
    IBOutlet NSTextField *txtFTPDir;
    IBOutlet NSTextField *txtFTPFilePath;
    IBOutlet NSTextField *txtFTPConnectState;
    
    IBOutlet NSComboBox *cmbDataType;
    IBOutlet NSMatrix* mtFactoryYade;
    IBOutlet NSTabView *tabView1;
    
    //
    IBOutlet NSTableView *tableView;
    
    NSMutableArray *array;
    NSInteger tableRow;

    NSThread* DBThread;
    NSThread* FTPThread;
    NSLock* _lock;
}

@property  NSString* strPartNum;



-(void) writePlist;
-(void) readPlist;
-(void) testDBConnect;
-(void) testFTPConnect;
-(void) showAlertMsg:(NSString*)msg;
-(NSString*) getHostName;
-(NSString*) getFilePath:(NSString*)pathURL;
-(void) initTableView;
-(void) initTableView1;
-(void) deleteAllColumns;
-(void) doubleClickInTableView:(id)sender;
-(void) saveTarget;
-(void) writeLog:(NSString*) strMsg;
-(NSString*) getBlockFromFile:(NSString*)path;
-(NSString*) getBlockFromFile2:(NSString*)path;
-(NSString*) getBlockFromFile2:(NSString*)path Size:(int)size;
-(bool) checkFileTypeAndFileContent;
-(bool) checkFileTypeAndFileContent:(_LOCALDATATYPE)type;
-(NSString*) getConfigPath;
-(void) addComboxItems;
-(NSString*) getPathWithRoot:(NSString*)folder;
-(NSString*) getRoot;
-(void) createTempConfig;
-(NSString*) getTempFileName:(NSString*)fileType;
-(NSArray*) getAllTempFileType;
-(_LOCALDATATYPE) getTempFileType;
-(NSArray*) getAllTempFileName;
-(NSString*) getTempFilePath;
-(bool) checkFileTypeAndFileContentForMic:(NSString*)strPath;
-(NSString*) getPathByDeletePrefix:(NSString*)strPath;
-(bool) getPathByDeletePrefix1:(NSString**)strPath;
-(NSString*) getMaxLine:(NSString*)strPart;
-(void) saveMaxLine:(NSString*)strPart Line:(NSString*)line;

@end


@interface TabViewDelegate : NSObject <NSTabViewDelegate>
{
    IBOutlet NSComboBox *cmbDataType;
    IBOutlet NSTextField *txtMaxLine;
}

-(_LOCALDATATYPE) getTempFileType;

@end
