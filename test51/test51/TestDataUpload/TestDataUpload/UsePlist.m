//
//  UsePlist.m
//  TestDataUpload
//
//  Created by bubble on 1/8/16.
//  Copyright (c) 2016 bubble. All rights reserved.
//

#import "UsePlist.h"

@implementation UsePlist


-(id)initForSetting:(SettingDlg*)parent FileName:(NSString*)name
{
    self = [super init];
    if (self) {
        dlg=parent;
        fileName=name;
    }
    return self;
}

-(id)initForSys:(AppDelegate*)parent FileName:(NSString*)name
{
    self = [super init];
    if (self) {
        app=parent;
        fileName=name;
    }
    return self;
}

-(id)initForSetting:(SettingDlg*)parent
{
    return [self initForSetting:parent FileName:@"config.plist"];
}

-(id)initForSys:(AppDelegate*)parent
{
    return [self initForSys:parent FileName:@"config.plist"];
}

-(NSString*)getConfigPath
{
    NSString *fp01=[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
    return [fp01 stringByAppendingPathComponent:fileName];
}

-(bool)checkConfigFileExist
{
    @autoreleasepool {
        NSString *fp=[self getConfigPath];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:fp isDirectory:false]==NO) {
            return false;
        }
    }
    return true;
}

-(void)saveReadRow:(double)row
{
    @autoreleasepool {
        @try {
            NSDictionary *dict=nil;
            NSString *fp02=[self getConfigPath];
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:fp02 isDirectory:false]==NO){
                dict =[NSMutableDictionary new];
            }
            else{
                dict=[NSDictionary dictionaryWithContentsOfFile:fp02];
            }
            
            //
            [dict setValue:[NSString stringWithFormat:@"%0.0f",row] forKey:@"StartLine"];
            [dict writeToFile:fp02 atomically:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            
        }
    }
}

-(void)saveWorkDate
{
    @autoreleasepool {
        @try {
            NSDictionary *dict=nil;
            NSString *fp1=[self getConfigPath];
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:fp1 isDirectory:false]==NO){
                dict =[NSMutableDictionary new];
            }
            else{
                dict=[NSDictionary dictionaryWithContentsOfFile:fp1];
            }
            
            //
            NSDateFormatter* date1=[[NSDateFormatter alloc] init];
            [date1 setDateFormat:@"yyyyMMdd"];
            [dict setValue:[NSString stringWithFormat:@"%@",[date1 stringFromDate:[NSDate date]]] forKey:@"LastDate"];
            [dict writeToFile:fp1 atomically:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            
        }
    }
}

-(NSString*)getWorkDate
{
    @autoreleasepool {
        @try {
            NSDictionary *dict=nil;
            NSString *fp02=[self getConfigPath];
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:fp02 isDirectory:false]==NO){
                dict =[NSMutableDictionary new];
            }
            else{
                dict=[NSDictionary dictionaryWithContentsOfFile:fp02];
            }
            return [dict objectForKey:@"LastDate"];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            
        }
    }
}

-(double)getReadRow
{
    double rows=0.0;
    @autoreleasepool {
        @try {
            NSDictionary *dict=nil;
            NSString *fp02=[self getConfigPath];
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:fp02 isDirectory:false]==NO) {
                return 1;
            }
            else{
                dict=[NSDictionary dictionaryWithContentsOfFile:fp02];
            }
            
            NSString* str2=[dict objectForKey:@"StartLine"];
            if (str2!=nil) {
                rows=[str2 doubleValue];
            }
            else {
                rows=1;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            
        }
    }
    return rows;
}

-(void)getUserState
{
    @autoreleasepool {
        @try {
            NSDictionary *dict;
            NSString *fp02=[self getConfigPath];
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:fp02 isDirectory:false]==NO) {
                return;
            }
            
            //
            dict=[NSDictionary dictionaryWithContentsOfFile:fp02];
            NSDictionary* user =[dict objectForKey:@"UserInfo"];
            [app->txtBarcodeFormat setStringValue:[user objectForKey:@"BarcodeFormat"]];
            [app->txtPartNo setStringValue:[user objectForKey:@"PartNum"]];
            [app->txtWorkNo setStringValue:[user objectForKey:@"WorkNum"]];
            [app->txtWorkOrder setStringValue:[user objectForKey:@"WorkOrder"]];
            [app->txtFixtureNo setStringValue:[user objectForKey:@"FixtureNum"]];
            [app->txtLineNo setStringValue:[user objectForKey:@"LineNum"]];
            
            //
            app->tsTotal=[[user objectForKey:@"Total"] doubleValue];
            app->tsPass=[[user objectForKey:@"Pass"] doubleValue];
            app->tsFail=[[user objectForKey:@"Fail"] doubleValue];
            app->tsRate=[[user objectForKey:@"Rate"] doubleValue];
            [app showRate];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            
        }
    }
}

-(void)saveUserState
{
    @autoreleasepool {
        @try {
            NSDictionary *dict=nil;
            NSDictionary *user=nil;
            NSString *fp02=[self getConfigPath];
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:fp02 isDirectory:false]==NO){
                dict =[NSMutableDictionary new];
                user =[NSMutableDictionary new];
            }
            else{
                dict=[NSDictionary dictionaryWithContentsOfFile:fp02];
                user =[NSMutableDictionary new];
            }
            
            [user setValue:[app->txtBarcodeFormat stringValue] forKey:@"BarcodeFormat"];
            [user setValue:[app->txtPartNo stringValue] forKey:@"PartNum"];
            [user setValue:[app->txtWorkNo stringValue] forKey:@"WorkNum"];
            [user setValue:[app->txtWorkOrder stringValue] forKey:@"WorkOrder"];
            [user setValue:[app->txtFixtureNo stringValue] forKey:@"FixtureNum"];
            [user setValue:[app->txtLineNo stringValue] forKey:@"LineNum"];
            [user setValue:[NSString stringWithFormat:@""] forKey:@"Total"];
            [user setValue:[NSString stringWithFormat:@"%1.0f",app->tsTotal] forKey:@"Total"];
            [user setValue:[NSString stringWithFormat:@"%1.0f",app->tsPass] forKey:@"Pass"];
            [user setValue:[NSString stringWithFormat:@"%1.0f",app->tsFail] forKey:@"Fail"];
            [user setValue:[NSString stringWithFormat:@"%1.0f",app->tsRate] forKey:@"Rate"];
            [dict setValue:user forKey:@"UserInfo"];
            [dict writeToFile:fp02 atomically:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            
        }
    }
    
}

-(void)getSysConfig
{
    [self writeLog:@"call function: getConfig()"];
    @autoreleasepool {
        @try {
            NSDictionary *dict;
            NSString *fp02=[self getConfigPath];
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:fp02 isDirectory:false]==NO) {
                return;
            }
            
            //
            dict=[NSDictionary dictionaryWithContentsOfFile:fp02];
            NSDictionary* db =[dict objectForKey:@"Database"];
            app->strDBIP=[db objectForKey:@"IP"];
            app->strDBName=[db objectForKey:@"DB"];
            app->strDBID=[db objectForKey:@"ID"];
            app->strDBPWD=[db objectForKey:@"PWD"];
            
            //
            NSDictionary* data =[dict objectForKey:@"Data"];
            app->strFileType=[data objectForKey:@"Type"];
            app->strFilePath=[data objectForKey:@"Path"];
            
            //
            NSDictionary* ftp =[dict objectForKey:@"FTP"];
            app->strFTPIP=[ftp objectForKey:@"IP"];
            app->strFTPPort=[ftp objectForKey:@"Port"];
            app->strFTPID=[ftp objectForKey:@"ID"];
            app->strFTPPWD=[ftp objectForKey:@"PWD"];
            app->strFTPDir=[ftp objectForKey:@"Dir"];
            app->strFTPFilePath=[ftp objectForKey:@"Path"];
            
            //
            app->bUseRunStart=[[dict objectForKey:@"UseRunStart"]intValue]==1 ? true : false;
            app->bUseCheckBarcode=[[dict objectForKey:@"UseCheckBarcode"]intValue]==1 ? true : false;
            app->bUseFTP=[[dict objectForKey:@"UseFTP"]intValue]==1 ? true : false;
            app->bUseAgainstCheat=[[dict objectForKey:@"UseAgainstCheat"]intValue]==1 ? true : false;
            app->bUseRenameFiles=[[dict objectForKey:@"UseRenameFiles"]intValue]==1 ? true : false;
            app->strFactory=[dict objectForKey:@"FactoryYade"];
            
            //
            NSString* str1=[dict objectForKey:@"PollTime"];
            if (str1 !=nil) {
                app->readPoll=[str1 doubleValue]/1000.0;
            }
            else {
                app->readPoll=1;
            }
            NSString* str2=[dict objectForKey:@"StartLine"];
            if (str2 !=nil) {
                app->readRow=[str2 doubleValue];
            }
            else {
                app->readRow=1;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            
        }
    }
}

-(void)writeLog:(NSString*)strMsg
{
    @autoreleasepool {
        UserLog* log=[[UserLog alloc]init:app];
        [log writeLog:strMsg];
    }
}

@end
