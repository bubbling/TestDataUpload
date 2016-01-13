//
//  AppDelegate.m
//  DataCreate
//
//  Created by bubble on 12/8/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(IBAction)selectFilePath:(id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setResolvesAliases:YES];
    [openPanel setPrompt:@"Select"];
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        [openPanel close];
        if (result == NSFileHandlingPanelOKButton) {
            NSString* strFile=[[openPanel URLs] objectAtIndex:0];
            if (sender==btnBrowse) {
                [txtFilePath setStringValue:strFile];
            }
        }
    }];
}


-(IBAction)startCraete:(id)sender
{
    if (timer==nil) {
        timer=[NSTimer scheduledTimerWithTimeInterval:[[txtTimerInterval stringValue] intValue] target:self selector:@selector(dataProc:) userInfo:nil repeats:YES];
    }
}


-(IBAction)stopCreate:(id)sender
{
    [timer invalidate];
    timer=nil;
    
}

-(void)dataProc:(NSTimer*)tmr
{
    @try {
        NSString* strPath=[txtFilePath stringValue];
        NSRange rang=[strPath rangeOfString:@"file:"];
        if (rang.location==0) {
            strPath=[strPath substringFromIndex:rang.location+5];
        }
        
        //
        NSFileManager* fm = [[NSFileManager alloc] init];
        if ([fm fileExistsAtPath:strPath isDirectory:nil]==YES) {
            NSFileHandle *logFile= [NSFileHandle fileHandleForWritingAtPath:strPath];
            [logFile seekToEndOfFile];
            NSMutableData *buffer = [[NSMutableData alloc] init];
            [buffer appendData:[[txtLineText stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
            [buffer appendData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [logFile writeData:buffer];
            [logFile closeFile];
            
            //
            rowsNum++;
            [txtLineNum setStringValue:[NSString stringWithFormat:@"Total Lines:%1.0f",rowsNum]];
        }
    }
    @catch (NSException *exception) {
        
    }
}

-(IBAction)writeManual:(id)sender
{
    if (timer!=nil) {
        [timer invalidate];
        timer=nil;
    }

    //
    @try {
        NSString* strPath=[txtFilePath stringValue];
        NSRange rang=[strPath rangeOfString:@"file:"];
        if (rang.location==0) {
            strPath=[strPath substringFromIndex:rang.location+5];
        }
        
        //
        NSFileManager* fm = [[NSFileManager alloc] init];
        if ([fm fileExistsAtPath:strPath isDirectory:nil]==YES) {
            NSFileHandle *logFile= [NSFileHandle fileHandleForWritingAtPath:strPath];
            [logFile seekToEndOfFile];
            NSMutableData *buffer = [[NSMutableData alloc] init];
            [buffer appendData:[[txtLineText stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
            [buffer appendData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [logFile writeData:buffer];
            [logFile closeFile];
            
            //
            rowsNum++;
            [txtLineNum setStringValue:[NSString stringWithFormat:@"Total Lines:%1.0f",rowsNum]];
        }
    }
    @catch (NSException *exception) {
        
    }
}

@end
