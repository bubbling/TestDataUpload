//
//  AnalyzeData.h
//  TestDataUpload
//
//  Created by bubble on 1/8/20.
//  Copyright (c) 2020 bubble. All rights reserved.
//

#ifndef AnalyzeData_h
#define AnalyzeData_h


#import "AppDelegate.h"
#import "FileLine.h"
#import "UserLog.h"

@interface AnalyzeData : NSObject
{
    AppDelegate* myApp;
    _LOCALDATATYPE myDataType;
    _DATATABLE myDbTable;
    _LOCALDATETIME myLocalTime;
    
    double sameBarcodes;
    NSMutableArray* arrBarcode;
    NSMutableArray* arrResult;
    NSMutableArray* arrTime;
}



-(double)getMaxLine:(NSString*)strID;
-(bool)isTestResult:(NSString*)strResult;
-(bool)getPathByDeletePrefix:(NSString**)strPath;
-(NSString*)getTestDateTime:(_LOCALDATETIME)datetime;
-(NSString*)modifyBansheeTestTime:(NSString*)strTime;
-(NSString*)modifyProxTestDate:(NSString*)strDate;
-(NSString*)getBansheeFilePathByCreateTime:(NSString*)strPath;
-(NSString*)getFilePathByCreateTimeAndPart:(NSString*)strPath;
-(NSString*)getFilePathByCreateTimeAndProx:(NSString*)strPath;
-(NSString*)getFileNameByLastModifyDate:(NSString*)strDir NameKey:(NSString*)strKey FileExt:(NSString*)strExt;
-(NSString*)getFileNameByLastModifyDate1:(NSString*)strDir NameKey:(NSString*)strKey FileExt:(NSString*)strExt;
-(NSArray*)getAllFileNameUnderDir:(NSString*)strDir FileExt:(NSString*)strExt;
-(NSArray*)getAllFileNameUnderDir:(NSString*)strDir NameKey:(NSString*)strKey FileExt:(NSString*)strExt;
-(NSArray*)getAllFileNameUnderDir1:(NSString*)strDir NameKey:(NSString*)strKey FileExt:(NSString*)strExt;
-(void)writeLog:(NSString*)strMsg;
-(void)saveStartLine:(NSString*)strID Line:(double)line;
-(double)getStartLine:(NSString*)strID;
-(void)getMicData:(NSString*)path;
-(void)getTabData:(NSString*)path;
-(void)getCommaData:(NSString*)path;
-(id)init:(AppDelegate*)parent;


@end


#endif