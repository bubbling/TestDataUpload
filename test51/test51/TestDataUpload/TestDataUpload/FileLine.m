//
//  FileLine.m
//  TestDataUpload
//
//  Created by bubble on 1/8/16.
//  Copyright (c) 2016 bubble. All rights reserved.
//

#import "FileLine.h"

//
@implementation FileLine


-(id)init:(NSString*)fileName LINETYPE:(_LINETYPE)type
{
    self = [super init];
    if (self) {
        // Initialization code here.
        strFileName=fileName;
        mLineType=type;
    }
    return self;
}

-(NSString*)getLineParamPath
{
    NSString *fp01=[[[[NSBundle mainBundle] bundlePath] stringByDeletingPathExtension] stringByDeletingLastPathComponent];
    return [fp01 stringByAppendingPathComponent:strFileName];
}

-(NSString*)getNowDate
{
    NSDateFormatter* date1=[[NSDateFormatter alloc] init];
    [date1 setDateFormat:@"yyyyMMdd"];
    return [date1 stringFromDate:[NSDate date]];
}

-(void)saveLine:(NSString*)strID Line:(double)line LINETYPE:(_LINETYPE)type
{
    if (strID==nil) {
        return;
    }
    
    if ([strID compare:@""]==NSOrderedSame){
        return;
    }
    
    @try {
        NSString* path1=[self getLineParamPath];
        NSString* path2=[NSString stringWithFormat:@"%@1",[self getLineParamPath]];
        
        if (access([path2 UTF8String], 0)==0) {
            remove([path2 UTF8String]);
        }
        FILE* f2=fopen([path2 UTF8String], "a");
        if (f2) {
            char buf2[255]={0};
            int tag1=0;
            
            if (type==SETTING_START_LINE) {
                sprintf(buf2, "#date:=%s\n",[[self getNowDate] UTF8String]);
                //注意：fwrite的第二个参数要用strlen,不能用sizeof
                fwrite(buf2, strlen(buf2), 1, f2);
            }

            //
            if (access([path1 UTF8String], 0)==0) {
                FILE* f1=fopen([path1 UTF8String], "r");
                char buf1[255]={0};
                
                if (f1) {
                    while(fgets(buf1, sizeof(buf1), f1)) {
                        //
                        char strBuf3[255]={0};
                        
                        if (type==SETTING_START_LINE) {
                            if (sscanf(buf1, "#date:=%254[^\n]",strBuf3)==1) {
                                if (strcmp(strBuf3, [[self getNowDate] UTF8String])!=0) {
                                    break;
                                }
                            }
                        }

                        //
                        memset(strBuf3, '\0', 255);
                        if (sscanf(buf1, "#param:=%254[^\n]",strBuf3)==1) {
                            char strBuf1[255]={0};
                            char strBuf2[255]={0};
                            
                            if(sscanf(strBuf3, "%254[^,]",strBuf1)==1){
                                int pos2=0;
                                while(strBuf3[pos2]!=',' && pos2<strlen(strBuf3)){pos2++;};
                                strncpy(strBuf2, strBuf3+pos2+1,strlen(strBuf3)-pos2-1);
                                
                                //
                                memset(buf2, '\0', 255);
                                if (strcmp(strBuf1, [strID UTF8String])==0) {
                                    sprintf(buf2, "#param:=%s,%1.0f\n",[strID UTF8String],line);
                                    tag1=1;
                                }
                                else
                                {
                                    sprintf(buf2, "#param:=%s,%s\n",strBuf1,strBuf2);
                                }
                                fwrite(buf2, strlen(buf2), 1, f2);
                            }
                        }
                    }
                    fclose(f1);
                    
                    //
                    if (tag1==0) {
                        memset(buf2, '\0', 255);
                        sprintf(buf2, "#param:=%s,%1.0f\n",[strID UTF8String],line);
                        fwrite(buf2, strlen(buf2), 1, f2);
                    }
                }
            }
            else{
                memset(buf2, '\0', 255);
                sprintf(buf2, "#param:=%s,%1.0f\n",[strID UTF8String],line);
                fwrite(buf2, strlen(buf2), 1, f2);
            }
        }
        fclose(f2);
        
        //
        if (access([path2 UTF8String], 0)==0) {
            if (access([path1 UTF8String], 0)==0) {
                remove([path1 UTF8String]);
            }
            rename([path2 UTF8String], [path1 UTF8String]);
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

-(double)getLine:(NSString*)strID
{
    @try {
        NSString* path1=[self getLineParamPath];
        NSString* path2=[NSString stringWithFormat:@"%@1",[self getLineParamPath]];
        
        if (access([path2 UTF8String], 0)==0) {
            remove([path2 UTF8String]);
        }
        
        if (access([path1 UTF8String], 0)==0) {
            FILE* f1=fopen([path1 UTF8String], "r");
            char buf1[255]={0};
            
            if (f1) {
                while(fgets(buf1, sizeof(buf1), f1)) {
                    //
                    char strBuf3[255]={0};
                    if (sscanf(buf1, "#date:=%254[^\n]",strBuf3)==1) {
                        if (strcmp(strBuf3, [[self getNowDate] UTF8String])!=0) {
                            fclose(f1);
                            remove([path1 UTF8String]);
                            return 0.0;
                        }
                    }
                    
                    //
                    memset(strBuf3, '\0', 255);
                    if (sscanf(buf1, "#param:=%254[^\n]",strBuf3)==1) {
                        char strBuf1[255]={0};
                        char strBuf2[255]={0};
                        
                        sscanf(strBuf3, "%254[^,]",strBuf1);
                        int pos2=0;
                        while(strBuf3[pos2]!=',' && pos2<strlen(strBuf3)){pos2++;};
                        strncpy(strBuf2, strBuf3+pos2+1,strlen(strBuf3)-pos2-1);
                        
                        //
                        if (strcmp(strBuf1, [strID UTF8String])==0) {
                            fclose(f1);
                            return strtod(strBuf2, nil);
                        }
                    }
                }
            }
            fclose(f1);
        }
        else
        {
            return 0.0;
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return 0.0;
}

-(void)saveLine:(NSString*)strID Line:(double)line
{
    if ([strID compare:@"" options:NSCaseInsensitiveSearch]==NSOrderedSame || strID==nil) {
        return ;
    }
    [self saveLine:strID Line:line LINETYPE:mLineType];
}

-(void)saveStartLine:(NSString*)strID Line:(double)line
{
    if ([strID compare:@"" options:NSCaseInsensitiveSearch]==NSOrderedSame || strID==nil) {
        return ;
    }
    [self saveLine:strID Line:line];
}
-(void)saveMaxLine:(NSString*)strID Line:(double)line
{
    if ([strID compare:@"" options:NSCaseInsensitiveSearch]==NSOrderedSame || strID==nil) {
        return ;
    }
    [self saveLine:strID Line:line];
}
-(double)getStartLine:(NSString*)strID
{
    if ([strID compare:@"" options:NSCaseInsensitiveSearch]==NSOrderedSame || strID==nil) {
        return 1.0;
    }
    return [self getLine:strID];
}
-(double)getMaxLine:(NSString*)strID
{
    if ([strID compare:@"" options:NSCaseInsensitiveSearch]==NSOrderedSame || strID==nil) {
        return 1.0;
    }
    return [self getLine:strID];
}
@end