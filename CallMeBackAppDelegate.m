//
//  CallMeBackAppDelegate.m
//  CallMeBack
//
//  Created by jrk on 30/10/09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import "CallMeBackAppDelegate.h"
#import <Skype/Skype.h>
#import "NSString+Search.h"

@implementation CallMeBackAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	connectedToSkype = NO;
	[SkypeAPI setSkypeDelegate: self];
	[SkypeAPI connect];
}

- (NSString*)clientApplicationName
{
	return @"Call Me Back Mutti";
}

- (void) skypeCall
{
	NSLog(@"calling back!");
	
	//tell application "Skype" to get URL "callto://don.vito._."
	[SkypeAPI sendSkypeCommand:@"CALL don.vito._."];
}

- (void)skypeAttachResponse:(unsigned)aAttachResponseCode
{
	NSLog(@"attach response: %i",aAttachResponseCode);
	if (aAttachResponseCode == 0)
	{	
		connectedToSkype = NO;
		return;
	}
	
	connectedToSkype = YES;
	
	if (!theTimer)
		theTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self selector:@selector(handleTimer:) userInfo: nil repeats: NO];
}

- (void)skypeNotificationReceived:(NSString*)aNotificationString
{
	NSLog(@"Skype notification: %@", aNotificationString);
	//- (BOOL) containsString:(NSString *)aString ignoringCase:(BOOL)flag;

	if ([aNotificationString containsString:@"UNPLACED" ignoringCase: YES])
	{
		NSLog(@"call is unplaced");
	}
	if ([aNotificationString containsString:@"INPROGRESS" ignoringCase: YES])
	{
		NSLog(@"call is running! let's open video!");
	
		NSArray *arr = [aNotificationString componentsSeparatedByString:@" "];
		if (callID != 0)
			NSLog(@"previous callID %i existed. strange!",callID);
		
		callID = [[arr objectAtIndex: 1] integerValue];
		//send command "ALTER CALL " & CallId & " START_VIDEO_SEND" script name "MyScript"
		
		NSString *videoCommand = [NSString stringWithFormat: @"ALTER CALL %i START_VIDEO_SEND", callID];
		
		[SkypeAPI sendSkypeCommand: videoCommand];

	}
	if ([aNotificationString containsString:@"FINISHED" ignoringCase: YES])
	{
		NSLog(@"Call finished!");
		NSArray *arr = [aNotificationString componentsSeparatedByString:@" "];
		NSInteger thisCallID = [[arr objectAtIndex: 1] integerValue];
		
		
		if (callID != thisCallID)
			NSLog(@"thisCallID %i != callID %i. strange.",thisCallID, callID);
		
		callID = 0;
		theTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self selector:@selector(handleTimer:) userInfo: nil repeats: NO];
	}
	
	
	if ([aNotificationString containsString:@"REFUSED" ignoringCase: YES] ||
		[aNotificationString containsString:@"FAILED" ignoringCase: YES] ||
		[aNotificationString containsString:@"MISSED" ignoringCase: YES] ||
		[aNotificationString containsString:@"BUSY" ignoringCase: YES] ||
		[aNotificationString containsString:@"CANCELLED" ignoringCase: YES]
		)
	{
		NSLog(@"Call failed somehow: %@!",aNotificationString);
		NSArray *arr = [aNotificationString componentsSeparatedByString:@" "];
		NSInteger thisCallID = [[arr objectAtIndex: 1] integerValue];
		
		
		if (callID != thisCallID)
			NSLog(@"thisCallID %i != callID %i. strange.",thisCallID, callID);
		
		callID = 0;
		theTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self selector:@selector(handleTimer:) userInfo: nil repeats: NO];
	}
	
	/*2009-10-30 15:50:58.213 CallMeBack[20769:a0f] Skype notification: CALL 899 STATUS UNPLACED
	 2009-10-30 15:50:58.213 CallMeBack[20769:a0f] Skype notification: CALL 899 STATUS ROUTING
	 2009-10-30 15:50:58.670 CallMeBack[20769:a0f] Skype notification: CALL 899 STATUS RINGING
	 2009-10-30 15:50:59.715 CallMeBack[20769:a0f] Skype notification: CALL 899 STATUS INPROGRESS
	 2009-10-30 15:50:59.753 CallMeBack[20769:a0f] Skype notification: CALL 899 DURATION 1
	 2009-10-30 15:51:00.758 CallMeBack[20769:a0f] Skype notification: CALL 899 DURATION 2
	 2009-10-30 15:51:01.760 CallMeBack[20769:a0f] Skype notification: CALL 899 DURATION 3
	 2009-10-30 15:51:02.759 CallMeBack[20769:a0f] Skype notification: CALL 899 DURATION 4
	 2009-10-30 15:51:03.759 CallMeBack[20769:a0f] Skype notification: CALL 899 DURATION 5
	 2009-10-30 15:51:04.760 CallMeBack[20769:a0f] Skype notification: CALL 899 DURATION 6
	 2009-10-30 15:51:05.763 CallMeBack[20769:a0f] Skype notification: CALL 899 DURATION 7
	 2009-10-30 15:51:06.761 CallMeBack[20769:a0f] Skype notification: CALL 899 DURATION 8
	 2009-10-30 15:51:07.761 CallMeBack[20769:a0f] Skype notification: CALL 899 DURATION 9
	 2009-10-30 15:51:08.754 CallMeBack[20769:a0f] Skype notification: CALL 899 DURATION 10
	 2009-10-30 15:51:09.801 CallMeBack[20769:a0f] Skype notification: CALL 899 DURATION 11
	 2009-10-30 15:51:10.793 CallMeBack[20769:a0f] Skype notification: CALL 899 DURATION 12
	 2009-10-30 15:51:10.931 CallMeBack[20769:a0f] Skype notification: CALL 899 STATUS FINISHED
*/	 
}

- (void)skypeBecameAvailable:(NSNotification*)aNotification
{
	NSLog(@"skype became aviable!");
	if (!connectedToSkype)
	{
		[SkypeAPI setSkypeDelegate: self];
		[SkypeAPI connect];
	}
}

- (void)skypeBecameUnavailable:(NSNotification*)aNotification
{
	NSLog(@"skype quit!");
	connectedToSkype = NO;
	[theTimer invalidate];
	//[theTimer release];
	theTimer = nil;
}

- (void) handleTimer: (NSTimer *) timer
{
	if (!connectedToSkype)
	{
		NSLog(@"we're not connected to skype!");
		return;
	}
	
	NSLog(@"- handleTimer:");
	NSString *timeStampString = [NSString stringWithContentsOfURL: [NSURL URLWithString: @"http://www.superking.org/callmeback.txt"]];
	NSLog(@"timestamp string: %@",timeStampString);
	
	if (!timeStampString)
	{	
		
		NSLog(@"No timestamp string! Rescheduling.");
		theTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self selector:@selector(handleTimer:) userInfo: nil repeats: NO];
		return;
	}
	
	NSInteger timeStamp = [timeStampString integerValue];
	NSLog(@"timestamp: %i", timeStamp);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger lastCalledStamp = [defaults integerForKey: @"lastCalled"];
	NSLog(@"lastCalled: %i", lastCalledStamp);
	
	//let's call
	if (timeStamp > lastCalledStamp)
	{
		NSDate *now = [NSDate date];
		NSInteger nowStamp = [now timeIntervalSince1970];
		[defaults setInteger: nowStamp forKey: @"lastCalled"];
		[self skypeCall];
	
		//our timer will be restored when the call ends!
		return;
	}

	//no call - let's check in 10 secs again
	theTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self selector:@selector(handleTimer:) userInfo: nil repeats: NO];
}

@end
