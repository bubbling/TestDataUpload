//
//  FileLine.h
//  TestDataUpload
//
//  Created by bubble on 1/8/16.
//  Copyright (c) 2016 bubble. All rights reserved.
//

#ifndef FileLine_h
#define FileLine_h


#import <Foundation/Foundation.h>


typedef enum
{
    SETTING_START_LINE=0,
    SETTING_MAX_LINE=1
}_LINETYPE;

@interface FileLine : NSObject
{
    NSString* strFileName;
    NSString* strFilePath;
    _LINETYPE mLineType;
}

-(void)saveLine:(NSString*)strID Line:(double)line LINETYPE:(_LINETYPE)type;
-(void)saveLine:(NSString*)strID Line:(double)line;
-(void)saveStartLine:(NSString*)strID Line:(double)line;
-(void)saveMaxLine:(NSString*)strID Line:(double)line;
-(id)init:(NSString*)fileName LINETYPE:(_LINETYPE)type;
-(double)getLine:(NSString*)strID;
-(double)getStartLine:(NSString*)strID;
-(double)getMaxLine:(NSString*)strID;
-(NSString*)getLineParamPath;
-(NSString*)getNowDate;


@end


#endif