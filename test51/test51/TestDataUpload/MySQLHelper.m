//
//  MysqlDB.m
//  TestDataUpload
//
//  Created by bubble on 11/11/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#import "MySQLHelper.h"


//
@implementation MysqlString


-(id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        arrField =[NSMutableArray new];
        arrValue =[NSMutableArray new];
    }
    return self;
}

//
-(void)addInsertParam:(NSString*)strTable Field:(NSString*)strField Value:(NSString*)strValue
{
    strTableName=strTable;
    [arrField addObject:strField];
    [arrValue addObject:strValue];
}

-(NSString*)stringInsertSQL
{
    if ([arrField count]>0) {
        NSString* strSQLField=@"";
        NSString* strSQLValue=@"";
        for (int i=0;i<[arrField count];i++) {
            strSQLField=[strSQLField stringByAppendingString:[NSString stringWithFormat:@"%@,",arrField[i]]];
            strSQLValue=[strSQLValue stringByAppendingString:[NSString stringWithFormat:@"'%@',",arrValue[i]]];
        }
        strSQLField=[strSQLField substringToIndex:[strSQLField length]-1];
        strSQLValue=[strSQLValue substringToIndex:[strSQLValue length]-1];
        return [NSString stringWithFormat:@"insert into %@(%@) values(%@)",strTableName,strSQLField,strSQLValue];
    }
    return nil;
}

@end


//
@implementation MysqlDB


-(id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        arrField =[NSMutableArray new];
        arrValue =[NSMutableArray new];
    }
    
    return self;
}

-(NSString*)getErrMSg
{
    return strErrMsg;
}

-(BOOL)connect:(NSString *)host User:(NSString *)user Password:(NSString *)password DB:(NSString *)db
{
    strErrMsg=nil;
    
    @try {
        mysql_init(&mysql);
        if(mysql_real_connect(&mysql,
                              [host UTF8String],
                              [user UTF8String],
                              [password UTF8String],
                              [db UTF8String],
                              3306,
                              NULL,
                              0))
        {
            strErrMsg=@"connect database success.";
        }
        else
        {
            strErrMsg=@"can not connect database.";
            mysql_close(&mysql);
            return false;
        }
        
    }
    @catch (NSException *exception) {
        strErrMsg =[NSString stringWithFormat:@"crash message:%@",[NSException debugDescription]];
        mysql_close(&mysql);
        return false;
    }
    @finally
    {
        //TODO:
    }
    return true;
}

-(void)close
{
    mysql_close(&mysql);
}

-(NSString*)getServerTime
{
    MYSQL_RES* result;
    NSString* strVal;
    
    mysql_query(&mysql,"select date_format(sysdate(),'%Y%m%d %H%i%s') from dual");
    result=mysql_store_result(&mysql);
    strVal=[NSString stringWithFormat:@"%s",mysql_fetch_row(result)[0]];
    mysql_free_result(result);
    
    return strVal;
}

-(void)insertData:(NSString*)strSQL
{
    mysql_query(&mysql,[strSQL UTF8String]);
}

-(void)addInsertParam:(NSString*)strTable Field:(NSString*)strField Value:(NSString*)strValue
{
    strTableName=strTable;
    [arrField addObject:strField];
    [arrValue addObject:strValue];
}

-(NSString*)stringInsertSQL
{
    if ([arrField count]>0) {
        NSString* strSQLField=@"";
        NSString* strSQLValue=@"";
        for (int i=0;i<[arrField count];i++) {
            strSQLField=[strSQLField stringByAppendingString:[NSString stringWithFormat:@"%@,",arrField[i]]];
            strSQLValue=[strSQLValue stringByAppendingString:[NSString stringWithFormat:@"'%@',",arrValue[i]]];
        }
        strSQLField=[strSQLField substringToIndex:[strSQLField length]-1];
        strSQLValue=[strSQLValue substringToIndex:[strSQLValue length]-1];
        return [NSString stringWithFormat:@"insert into %@(%@) values(%@)",strTableName,strSQLField,strSQLValue];
    }
    return nil;
}

@end
