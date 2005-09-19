//
//  VECDCConnection.h
//  DirectConnectTest3.1
//
//  Created by Varun Mehta on 6/18/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
   VECDCConnectionEventNone = 0,
   VECDCConnectionEventOpenCompleted = 1 << 0,
   VECDCConnectionEventHasStringAvailable = 1 << 1,
   VECDCConnectionEventHasSpaceAvailable = 1 << 2,
   VECDCConnectionEventErrorOccurred = 1 << 3,
   VECDCConnectionEventEndEncountered = 1 << 4
} VECDCConnectionEvent;

@interface VECDCConnection : NSObject
{
	NSInputStream * fromHost;
	NSOutputStream * toHost;
	NSString *inputBuffer;
	uint8_t buffer[4096];
	id delegate;
}

- (bool) connectToHost;
- (bool) disconnectFromHost;
- (void) setDelegate: (id) delegate;
- (void)parseCommand:(NSString *) theCommand;
- (char *)lockToKey:(NSString *) lock;
- (void) sendString:(NSString *) string;
- (void)sendInfoString;

@end