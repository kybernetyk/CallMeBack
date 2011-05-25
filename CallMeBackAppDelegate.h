//
//  CallMeBackAppDelegate.h
//  CallMeBack
//
//  Created by jrk on 30/10/09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Skype/Skype.h>

@interface CallMeBackAppDelegate : NSObject <NSApplicationDelegate, SkypeAPIDelegate> 
{
    NSWindow *window;
	BOOL connectedToSkype;
	
	NSTimer *theTimer;
	NSInteger callID;
}

@property (assign) IBOutlet NSWindow *window;

@end
