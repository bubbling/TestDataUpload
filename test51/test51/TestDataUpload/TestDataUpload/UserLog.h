//
//  UseLog.h
//  TestDataUpload
//
//  Created by bubble on 1/9/16.
//  Copyright (c) 2016 bubble. All rights reserved.
//

#ifndef UserLog_h
#define UserLog_h

#import <Foundation/Foundation.h>
#import "AppDelegate.h"



@interface UserLog : NSObject
{
    AppDelegate* myApp;
}


-(NSString*)getTestDateTime:(_LOCALDATETIME)datetime;
-(void)writeLog:(NSString*)strMsg;
-(id)init:(AppDelegate*)parent;


@end

#endif
