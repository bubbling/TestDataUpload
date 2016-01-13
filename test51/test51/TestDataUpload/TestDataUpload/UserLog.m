//
//  UseLog.m
//  TestDataUpload
//
//  Created by bubble on 1/9/16.
//  Copyright (c) 2016 bubble. All rights reserved.
//

#import "UserLog.h"

@implementation UserLog


-(id)init:(AppDelegate*)parent
{
    self = [super init];
    if (self) {
        // Initialization code here.
        myApp=parent;
    }
    return self;
}

-(NSString*)getTestDateTime:(_LOCALDATETIME)datetime
{
    NSDateFormatter* fm=[[NSDateFormatter alloc] init];
    switch (datetime) {
        case 0:  [fm setDateFormat:@"yyyyMMdd"];         break;
        case 1:  [fm setDateFormat:@"HHmmss"];           break;
        case 2:  [fm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];    break;
        default:
            break;
    }
    return [fm stringFromDate:[NSDate date]];
}

-(void)writeLog:(NSString*) strMsg
{
    [myApp showRun:strMsg];
    
    //
    @autoreleasepool {
        @try {
            NSDateFormatter* dateFMT1=[[NSDateFormatter alloc] init];
            [dateFMT1 setDateFormat:@"yyyyMMdd"];
            NSString* fPName=[[dateFMT1 stringFromDate:[NSDate date]] stringByAppendingString:@".log"];
            
            //
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *fp01=[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
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
                if([[dic objectForKey:@"NSFileSize"] doubleValue]>1024*1024*1) {
                    [fm removeItemAtPath:fpath error:nil];
                    [fm createFileAtPath:fpath contents:nil attributes:nil];
                }
            }
            
            //
            NSFileHandle *logFile= [NSFileHandle fileHandleForWritingAtPath:fpath];
            [logFile seekToEndOfFile];
            NSMutableData *buffer = [[NSMutableData alloc] init];
            [buffer appendData:[[self getTestDateTime:LOCAL_DATE_TIME] dataUsingEncoding:NSUTF8StringEncoding]];
            [buffer appendData:[@": " dataUsingEncoding:NSUTF8StringEncoding]];
            [buffer appendData:[strMsg dataUsingEncoding:NSUTF8StringEncoding]];
            [buffer appendData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [logFile writeData:buffer];
            [logFile closeFile];
        }
        @catch (NSException *exception) {
            
        }
    }
}


@end
