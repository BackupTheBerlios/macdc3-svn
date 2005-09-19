//
//  VECDCConnection.m
//  DirectConnectTest3.1
//
//  Created by Varun Mehta on 6/18/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "VECDCConnection.h"


@implementation VECDCConnection

- (id)init
{
    self = [super init];
    if (self) {
		delegate = self;
	}
    return self;
}

- (bool) connectToHost
{
	NSLog(@"Opening connection to host");
	[NSStream getStreamsToHost:[NSHost hostWithName:@"cudc.dyndns.org"] port:4040
		inputStream:&fromHost outputStream:&toHost];
	[fromHost retain]; [toHost retain];
	[fromHost setDelegate: self]; [toHost setDelegate: self];
	[fromHost scheduleInRunLoop:[NSRunLoop currentRunLoop]
		forMode:NSDefaultRunLoopMode];
	[toHost scheduleInRunLoop:[NSRunLoop currentRunLoop]
		forMode:NSDefaultRunLoopMode];
	[fromHost open]; [toHost open];
	return YES;
	
}

- (bool) disconnectFromHost
{
	[fromHost close];
	[toHost close];
	[fromHost release];
	[toHost release];
	return YES;
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
	int bytes;
	NSLog(@"Delegate called: %d", (NSStreamEvent)streamEvent);
	if (streamEvent == NSStreamEventHasBytesAvailable)
	{
		bytes = [(NSInputStream*)theStream read:(UInt8*)&buffer maxLength:sizeof(buffer)];
		NSString *inputString = [[NSString alloc]
			initWithBytes:&buffer length:bytes encoding:NSUTF8StringEncoding];
		NSLog(@"%@", inputString);
		//[textField insertText:inputString];
		//[textField insertText:@"\n"];
		NSArray *inputLines = [inputString componentsSeparatedByString:@"|"];
 		NSEnumerator *enumerator = [inputLines objectEnumerator];
		NSString *aCommand = [enumerator nextObject];
		do
		{
			//[textField insertText:@"Command: "];
			//[textField insertText:aCommand];
			//[textField insertText:@"\n"];
			[delegate connectionEvent: VECDCConnectionEventHasStringAvailable onConnection: self withData: aCommand];
			[self parseCommand:aCommand];
		} while (aCommand = [enumerator nextObject]);
	}
}

- (void)parseCommand:(NSString *) theCommand
{
	NSString *command, *arguments;
	char *key;
	int location = [theCommand rangeOfString:@" "].location;
	if (location >= 0 && location < [theCommand length])
	{
		NSLog(@"%d", location);
		command = [theCommand substringToIndex:([theCommand rangeOfString:@" "].location)];
		arguments = [theCommand substringFromIndex:([theCommand rangeOfString:@" "].location)];
	}
	else
		command = theCommand;
		
	NSLog(@"%@ <- command", command);
	
	if ([command caseInsensitiveCompare:@"$Lock"] == NSOrderedSame)
	{
		NSString *lock = [arguments substringToIndex:([arguments rangeOfString:@" Pk="].location)];
		key = [self lockToKey:lock];
		int length = 0;
		while (key[length] != '\0')
			length++;
		NSString *fullKey = [NSString stringWithFormat:@"$Key %s|", key];
		[self sendString:fullKey];
		[self sendString:[NSString stringWithString:@"$ValidateNick smartperson|"]];
	}
	else if ([theCommand caseInsensitiveCompare:@"$GetPass"] == NSOrderedSame)
	{
		NSLog(@"Asking for Pass!");
		[self sendString:[NSString stringWithString:@"$MyPass 78963a|"]];
	}
	else if ([command caseInsensitiveCompare:@"$LogedIn"] == NSOrderedSame)
	{
		[self sendString:[NSString stringWithString:@"$Version 1.0091|$GetNickList|"]];
		NSLog(@"Time to send info!");
		[self sendInfoString];
	}
}

- (void)sendString:(NSString *)aString
{
	NSLog(aString);
	[toHost write:(uint8_t *)([aString UTF8String])
		maxLength:([aString length]+1)*sizeof(uint8_t)];
	[toHost write:(uint8_t *)("|") maxLength:1];
}

- (void)sendInfoString
{
	char infoString[] ="$MyINFO $ALL smartperson something$ $Cable";
	[toHost write:(uint8_t *)(infoString) maxLength:(strlen(infoString)*sizeof(uint8_t))];
	char speedByte = 1;
	[toHost write:(uint8_t *)(&speedByte) maxLength:(sizeof(uint8_t))];
	char infoString2[] = "$someone@something.com$1000000000$|";
	[toHost write:(uint8_t *)(infoString2) maxLength:(strlen(infoString2)*sizeof(uint8_t))];
	NSLog(@"%s", infoString);
}

- (void)sendKey:(char *)someBytes ofLength:(int)length
{
/*	NSMutableData *someData;
	someData = [NSMutableData dataWithData:[[NSString stringWithString:@"$Key "] dataUsingEncoding:NSUTF8StringEncoding]];
	[someData appendBytes:someBytes length:length];
	[someData appendData:[NSData dataWithData:[[NSString stringWithString:@"|"] dataUsingEncoding:NSUTF8StringEncoding]]];
	[toHost write:(uint8_t *)[someData bytes] maxLength:[someData length]];
*/}

- (char *)lockToKey:(NSString *)lock
{
	int i = 0, length = 0, realKeyLength = 0, realKeyPos = 0;
	length = [lock length];
	char *key = new char[length + 1];
	char *realKey; char buffer[5];
	NSString *realKeyString;
	for (i = 1; i < length; i++)
	{
        key[i] = ([lock characterAtIndex:i] ^ [lock characterAtIndex:i-1]);
	}
	
	key[0] = [lock characterAtIndex:0] ^ [lock characterAtIndex:length-1] ^ [lock characterAtIndex:length-2] ^ 5;
	key[length] = '\0';
	
	for (i = 0; i < length; i++)
    {
		key[i] = ((key[i]<<4) & 240) | ((key[i]>>4) & 15);
		if (key[i] == 0 || key[i] == 5 || key[i] == 36 || key[i] == 96 || key[i] == 124)
			realKeyLength += 10;
		else realKeyLength++;
	}
	realKey = new char[realKeyLength+1];
	realKeyPos = 0;
	for (i = 0; i < length; i++)
	{
		if (key[i] == 0 || key[i] == 5 || key[i] == 36 || key[i] == 96 || key[i] == 124)
		{
			realKey[realKeyPos] = '/'; realKey[realKeyPos+1] = 37; realKey[realKeyPos+2] = 'D'; realKey[realKeyPos+3] = 'C'; realKey[realKeyPos+4] = 'N';
			switch (key[i])
			{
				case 0:
					realKey[realKeyPos+5] = '0';
					realKey[realKeyPos+6] = '0';
					realKey[realKeyPos+7] = '0';
					break;
				case 5:
					realKey[realKeyPos+5] = '0';
					realKey[realKeyPos+6] = '0';
					realKey[realKeyPos+7] = '5';
					break;
				case 36:
					realKey[realKeyPos+5] = '0';
					realKey[realKeyPos+6] = '3';
					realKey[realKeyPos+7] = '6';
					break;
				case 96:
					realKey[realKeyPos+5] = '0';
					realKey[realKeyPos+6] = '9';
					realKey[realKeyPos+7] = '6';
					break;
				case 124:
					realKey[realKeyPos+5] = '1';
					realKey[realKeyPos+6] = '2';
					realKey[realKeyPos+7] = '4';
					break;
			}
			realKey[realKeyPos+8] = '%'; realKey[realKeyPos+9] = '/';
			realKeyPos += 10;
		}
		else
		{
			realKey[realKeyPos] = key[i];
			realKeyPos++;
		}
	}
	realKey[realKeyLength] = '\0';
	delete[] key;
	return realKey;
	//realKeyString = [[NSString alloc] initWithCString:realKey length:realKeyLength+1];
	//return realKeyString;
}

- (void) setDelegate:(id)newDelegate
{
	delegate = newDelegate;
	[toHost setDelegate: delegate];
	[fromHost setDelegate: delegate];
}

- (id) delegate
{
	return delegate;
}

@end
