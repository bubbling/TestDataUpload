//
//  AppDelegate.h
//  DataCreate
//
//  Created by bubble on 12/8/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSTextField* txtFilePath;
    IBOutlet NSTextField* txtTimerInterval;
    IBOutlet NSTextField* txtLineText;
    IBOutlet NSTextField* txtLineNum;
    
    IBOutlet NSButton* btnStart;
    IBOutlet NSButton* btnStop;
    IBOutlet NSButton* btnBrowse;
    IBOutlet NSButton* btnManual;
    
    
    NSTimer* timer;
    double rowsNum;
    
}

-(void)dataProc:(NSTimer*)tmr;


@end

