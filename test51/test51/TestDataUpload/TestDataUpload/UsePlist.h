//
//  UsePlist.h
//  TestDataUpload
//
//  Created by bubble on 1/8/16.
//  Copyright (c) 2016 bubble. All rights reserved.
//

#ifndef UsePlist_h
#define UsePlist_h


#import <Foundation/Foundation.h>
#import "SettingDlg.h"
#import "AppDelegate.h"
#import "UserLog.h"

@interface UsePlist : NSObject
{
    SettingDlg* dlg;
    AppDelegate* app;
    NSString* fileName;
}

-(void)writeLog:(NSString*)strMsg;
-(void)saveUserState;
-(void)saveReadRow:(double)row;
-(bool)checkConfigFileExist;
-(NSString*)getWorkDate;
-(NSString*)getConfigPath;
-(void)saveWorkDate;
-(void)getUserState;
-(void)getSysConfig;
-(id)initForSetting:(SettingDlg*)parent FileName:(NSString*)name;
-(id)initForSys:(AppDelegate*)parent FileName:(NSString*)name;
-(id)initForSetting:(SettingDlg*)parent;
-(id)initForSys:(AppDelegate*)parent;



@end


#endif