//
//  AppDelegate.h
//  test6
//
//  Created by bubble on 9/23/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "SettingDlg.h"
#import "MDBufferedInputStream.h"
#import "FTPManager.h"
#import "MySQLHelper.h"
#import "StringHelper.h"
#import "IPAdress.h"
#import "SortHelper.h"
#import "UserDef.h"



@interface AppDelegate : NSObject <NSApplicationDelegate>
{
@public
    
    //
    IBOutlet NSTextField* txtLoginPWD;
    IBOutlet NSTextField* txtBarcodeFormat;
    IBOutlet NSTextField* txtPartNo;
    IBOutlet NSTextField* txtWorkNo;
    IBOutlet NSTextField* txtFixtureNo;
    IBOutlet NSTextField* txtWorkOrder;
    IBOutlet NSTextField* txtLineNo;
    IBOutlet NSTextField* txtTips;
    IBOutlet NSTextField* txtSTTotal;
    IBOutlet NSTextField* txtSTPass;
    IBOutlet NSTextField* txtSTFail;
    IBOutlet NSTextField* txtSTRate;
    IBOutlet NSTextField* txtHello;
    IBOutlet NSTextField* txtVersion;
    IBOutlet NSTextField* txtLogType;
    IBOutlet NSTextField* txtHourProduct;
    
    //
    IBOutlet NSButton* btnSetting;
    IBOutlet NSButton* btnLogin;
    IBOutlet NSButton* btnLoginOK;
    IBOutlet NSButton* btnLoginCancel;
    IBOutlet NSButton* btnStartUpload;
    IBOutlet NSButton* btnReUpload;
    IBOutlet NSButton* btnFtpUpload;
    
    IBOutlet NSMenuItem* mnSystem;
    IBOutlet NSTextView* txtRunView;
    IBOutlet NSTextView* txtHelpContent;
    IBOutlet NSTextView* txtErrView;
    
    //IBOutlet NSProgressIndicator* pgWork;  //进度条
    IBOutlet NSPanel *theSheet;
    IBOutlet NSPanel *AboutSheet;
    
    IBOutlet NSImageView *imgLeft;
    IBOutlet NSImageView *imgMiddle;
    IBOutlet NSImageView *imgRight;
    IBOutlet NSImageView *imgDBLink;
    IBOutlet NSImageView *imgFTPLink;
    IBOutlet NSImageView *imgBarChk;
    
    IBOutlet NSTabView *mainTab;
    
@public
    
    //user
    NSString* strBarcodeFormat;
    NSString* strPartNo;
    NSString* strWorkNo;
    NSString* strFixtureNo;
    NSString* strWorkOrder;
    NSString* strLineNo;
    
    //db
    NSString* strDBIP;
    NSString* strDBID;
    NSString* strDBPWD;
    NSString* strDBName;
    NSString* strFactory;
    NSString* strLocalIP;
    
    //local file
    NSString* strFileType;
    NSString* strFilePath;

    //ftp
    NSString* strFTPIP;
    NSString* strFTPID;
    NSString* strFTPPWD;
    NSString* strFTPPort;
    NSString* strFTPDir;
    NSString* strFTPFilePath;
    NSString* strLastBarcode;
    
    NSLock* _lock;
    NSThread* myThread;
    NSMutableArray* arrImgPos;
    NSDate* startProduct;
    
    
    bool bUseFTP;
    bool bUseRunStart;
    bool bUseCheckBarcode;
    bool bUseAgainstCheat;
    bool bUseRenameFiles;
    bool bLogin;
    bool bStartRunUpload;
    bool bDBConnect;
    bool bCheckBar;
    
    double tsTotal;
    double tsPass;
    double tsFail;
    double tsRate;
    double errBarcodeChk;
    double errDBLink;
    
    //
    double readRow;
    double readPoll;
    double logLine;
    double errLine;
    double hourProducts;
    
    int countHourProducts;
}

//
-(bool)checkUserInput;
-(bool)checkBarcode:(NSString*)strBar BarFormat:(NSString*) strFMT;
-(bool)checkDBConnect;
-(bool)checkFTPConnect;
-(bool)isMidNight;
-(bool)isFileExist:(NSString*)strPath;
-(bool)uploadData:(NSString*)barcode TestResult:(NSString*)result TestDate:(NSString*)date DataTable:(_DATATABLE)table;
-(bool)getPathByDeletePrefix:(NSString**)strPath;

-(_LOCALDATATYPE)getDataFileType;
-(NSString*)getFileType;
-(int)getFactoryType;

-(NSString*)getHostName;
-(NSString*)getDateTime:(NSString*)strDateTime isDate:(bool)useDate DateTable:(_DATATABLE)table;
-(NSString*)getReadMeContent;
-(NSString*)getNowDate;
-(NSString*)getReadMePath;
-(NSString*)getFTPPath;
-(NSString*)getLocalIP;
-(NSString*)readLineAsString:(FILE*)file;
-(NSString*)getTestDateTime:(_LOCALDATETIME)datetime;

-(void)showAlertMsg:(NSString*)msg;
-(void)showRun:(NSString*)msg;
-(void)showErr:(NSString*)msg;
-(void)showRate:(NSString*)result;
-(void)showRate;
-(void)getFileAttr:(NSString*)strPath;
-(void)createDirectoryUnderAppDirectory:(NSString*)strDir;
-(void)createDataFolder;
-(void)appendToMyTextView:(NSTextView*)myView ViewText:(NSString*)text;
-(void)clearMyTextView;
-(void)run;
-(void)autoUploadFTP:(NSString*)strPath;
-(void)uploadFtpFile:(NSString*)strPath;
-(void)writeLog:(NSString*)strMsg;
-(void)showRunState:(bool)runOK;
-(void)showRunState:(int)tag State:(int)state;
-(void)showHourProduct;



@end







