//
//  MyDocument.h
//  DirectConnectTest3
//
//  Created by Varun Mehta on 4/9/05.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#include <CoreFoundation/CoreFoundation.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>

#include <stdlib.h>

#import "VECDCConnection.h"

@interface MyDocument : NSDocument
{
    IBOutlet id commandField;
    IBOutlet id textField;
	VECDCConnection *hubConnection;
	
	uint8_t buffer[4096];
}

- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)send:(id)sender;
- (BOOL)connectionEvent:(VECDCConnectionEvent) event onConnection:(VECDCConnection *) connection withData:(NSString *) data;

@end

// Add your subclass-specific initialization here.
// If an error occurs here, send a [self release] message and return nil.
/*CFDataRef address;
address = CFDataCreate(NULL, (unsigned char*)&sin, sizeof(sin));
[super windowControllerDidLoadNib:aController];
// Add any code here that needs to be executed once the windowController has loaded the document's window.
struct sockaddr_in testAddr;
testAddr.sin_family = AF_INET;
testAddr.sin_port = htons(4080);
inet_aton("160.39.224.68", &(testAddr.sin_addr));
memset(&(testAddr.sin_zero),'\0',8);
CFSocketRef testSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET , SOCK_STREAM , IPPROTO_TCP ,kCFSocketDataCallBack|kCFSocketConnectCallBack, (CFSocketCallBack)&MyCallBack, NULL);
CFSocketError connectError = CFSocketConnectToAddress (testSocket, CFDataCreate(kCFAllocatorDefault,(UInt8 *)&(testAddr),sizeof(testAddr)) , 60 );

CFRunLoopSourceRef runLoopSource = NULL;
runLoopSource = CFSocketCreateRunLoopSource(NULL, testSocket, 0);
if(NULL != runLoopSource) {
	CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
}*/