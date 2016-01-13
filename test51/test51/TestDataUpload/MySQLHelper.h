//
//  MysqlDB.h
//  TestDataUpload
//
//  Created by bubble on 11/11/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mysql.h>


@interface MysqlDB : NSObject
{
    //error string
    NSString* strErrMsg;
    
    //Mysql object
    MYSQL mysql;
    
    NSMutableArray* arrField;
    NSMutableArray* arrValue;
    NSString* strTableName;
}


-(id)init;
-(BOOL)connect:(NSString *)host
    User:(NSString *)user
    Password:(NSString *)password
    DB:(NSString *)db;
-(NSString*)getErrMSg;
-(NSString*)getServerTime;
-(void)close;
-(void)insertData:(NSString*)strSQL;
-(void)addInsertParam:(NSString*)strTable Field:(NSString*)strField Value:(NSString*)strValue;
-(NSString*)stringInsertSQL;


@end


//
@interface MysqlString : NSObject
{
    NSMutableArray* arrField;
    NSMutableArray* arrValue;
    NSString* strTableName;
}
-(void)addInsertParam:(NSString*)strTable Field:(NSString*)strField Value:(NSString*)strValue;
-(NSString*)stringInsertSQL;


@end