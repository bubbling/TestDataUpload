//
//  Data.h
//  TestDataUpload
//
//  Created by bubble on 12/31/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#ifndef UserDef_h
#define UserDef_h

//#define TARGET_OS_X_10_9

//
extern NSString* const AppWindowTitle;


//data table name.
typedef enum
{
    MYSQL_ALS_ICT_DATA=0,
    MYSQL_Prox_FLUKE_DATA=1
}_DATATABLE;

//local date/time
typedef enum
{
    LOCAL_DATE=0,
    LOCAL_TIME=1,
    LOCAL_DATE_TIME=2
}_LOCALDATETIME;

//file format type
typedef enum
{
    DATA_TYPE_NONE=0,
    ALS_X109,
    ALS_X137,
    ALS_N69,
    ALS_J127,
    Prox_N56,
    Prox_N66,
    Prox_N71,
    Mic_X35,
    Mic_D10
}_LOCALDATATYPE;


//
@interface FileAttr : NSObject
{
    NSString *fileName;
    NSDate *fileCreateTime;
}

@property (readwrite,copy) NSString * fileName;
@property (readwrite,copy) NSDate * fileCreateTime;

@end

//
@interface TableData : NSObject
{
    NSString *appID;
    NSString *appName;
}

@property (readwrite,copy) NSString * appID;
@property (readwrite,copy) NSString * appName;

@end





#endif
