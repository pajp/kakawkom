//
//  KakawKom.m
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-07.
//  Copyright 2010 Rasmus Sten <rasmus@dll.nu>. All rights reserved.
//

#import "KakawKom.h"


@implementation KakawKom

- (id) initWithUser:(int) u password:(NSString*) p {
	self = [super init];
	if (self) {
		userId = u;
		password = p;
		[self init];		
	}
	return self;
}

- (id) init {
	self = [super init];
    if (self) {
		callSequence = eventCount = 0;
		readParseOffset = byteIndex = 0;
		canWrite = NO;
		sessionState = connectionState = KOM_DISCONNECTED;
		pendingCalls = [[NSMutableDictionary alloc] init];
		NSHost* host = [NSHost hostWithName:@"kom.lysator.liu.se"];
		[NSStream getStreamsToHost:host port:4894 inputStream:&iStream outputStream:&oStream];
		[iStream retain];
		[oStream retain];		
        [iStream setDelegate:self];
        [oStream setDelegate:self];
        [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
						   forMode:NSDefaultRunLoopMode];
        [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
						   forMode:NSDefaultRunLoopMode];
        [iStream open];
        [oStream open];
    }
    return self;
}

- (void)logData:(NSData *) data {
	NSLog(@"Logdata: \"%@\"", [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSISOLatin1StringEncoding]);
}

- (void)getText:(int)textNumber {
	NSLog(@"getText");
	NSMutableData* d = [[NSMutableData data] retain];
	[self sdcat:d asciiString:[NSString stringWithFormat:@"%d", textNumber]];
	[self separator:d];
	[self sdcat:d asciiString:@"0"]; // start-char
	[self separator:d];
	[self sdcat:d asciiString:@"87987123123129"]; // end-char
	[self sdcat:d asciiString:@"\n"];
	[self rpcSend:KOM_get_text parameters:d];
}

- (void)login {
	NSLog(@"login");
	NSData* pwd = [self hollerithFromString:password];
	int person = userId;
	NSLog(@"would login with password hollerith: %@", pwd);
	NSLog(@"which in English would be %@", [[NSString alloc] initWithBytes:[pwd bytes] length:[pwd length] encoding:NSISOLatin1StringEncoding]);
	NSString* personstr = [NSString stringWithFormat:@"%d ", person];
	NSMutableData* parameters = [[NSMutableData data] retain];
	[parameters appendData:[personstr dataUsingEncoding:NSASCIIStringEncoding]];
	[parameters appendData:pwd];
	[parameters appendData:[@" 1\n" dataUsingEncoding:NSASCIIStringEncoding]];
	loginSeqNo = [self rpcSend:KOM_login parameters:parameters];
}

- (void) setClientVersion:(NSString*)name version:(NSString*)version {
	NSMutableData* d = [[NSMutableData data] retain];
	[d appendData:[self hollerithFromString:name]];
	[self separator:d];
	[d appendData:[self hollerithFromString:version]];
	[self rpcSend:KOM_set_client_version parameters:d];
}

- (void) sdcat:(NSMutableData*)data asciiString:(NSString*)string {
	[data appendData:[string dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void) separator:(NSMutableData*) data {
	[self sdcat:data asciiString:@" "];
}

- (int) rpcSend:(int)call parameters:(NSData*) parameters {
	int seqno = ++callSequence;
	NSString* prefixStr = [NSString stringWithFormat:@"%d %d%s", seqno, call, [parameters length] > 0 ? " " : ""];
	NSMutableData* callData = [[NSMutableData data] retain];
	[callData appendData:[prefixStr dataUsingEncoding:NSASCIIStringEncoding]];
	[callData appendData:parameters];
	[callData appendData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding]];
	[self logData:callData];
	[_wdata setData:callData];
	[self send];
	NSNumber* callobj = [NSNumber numberWithInt:call];
	NSNumber* seqnoobj = [NSNumber numberWithInt:seqno];
	[pendingCalls setObject:callobj forKey:seqnoobj];
	return seqno;
}

- (NSData*)hollerithFromString:(NSString *) string {
	//NSLog(@"hollerithFromString:string=%@", string);
	NSMutableData* _d = [[NSMutableData data] retain];
	// convert to iso-8859-1 string
	NSMutableData* s = [[NSMutableData data] retain];
	[s setData:[string dataUsingEncoding:NSISOLatin1StringEncoding]];
	NSString* lstr = [NSString stringWithFormat:@"%dH", [s length]];
	NSData* lstrdata = [lstr dataUsingEncoding:NSASCIIStringEncoding];
	[_d appendBytes:[lstrdata bytes] length:[lstrdata length]];
	[_d appendBytes:[s bytes] length:[s length]];
	return _d;
}

- (BOOL)send {
	if (![oStream hasSpaceAvailable]) {
		NSLog(@"got send message but output stream has no space available");
		return NO;
	}
	int data_len = [_wdata length];
	if (data_len > byteIndex) {
		NSLog(@"Seems I have data to send (%d bytes)!", data_len);
		uint8_t *readBytes = (uint8_t *)[_wdata mutableBytes];
		readBytes += byteIndex; // instance variable to move pointer
		int data_len = [_wdata length];
		unsigned int len = ((data_len - byteIndex >= 1024) ?
							1024 : (data_len-byteIndex));
		uint8_t buf[len];
		(void)memcpy(buf, readBytes, len);
		len = [oStream write:(const uint8_t *)buf maxLength:len];
		byteIndex += len;
		NSLog(@"wrote %d bytes to output stream (byteIndex=%d)", len, byteIndex);
		if (byteIndex == data_len) {
			NSLog(@"wrote all %d bytes, resetting send buffer", data_len);
			[_wdata setLength:0];
			byteIndex = 0;
			return YES;
		}
	} else {
		NSLog(@"no data in buffer to send");
	}
	return NO;
	
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
	NSLog(@"handleEvent");
	eventCount++;
	NSLog(@"count: %d, stream: %@", eventCount, stream);
	if(!_wdata) {
		_wdata = [[NSMutableData data] retain];
	}
	if(!_rdata) {
		_rdata = [[NSMutableData data] retain];
	}
	
	
    switch(eventCode) {
		case NSStreamEventHasSpaceAvailable:
			NSLog(@"stream has space available");
			if (connectionState == KOM_ESTABLISHED) {
				if (byteIndex == 0) {
					NSHost* localhost = [NSHost currentHost];
					NSMutableData* d = [[NSMutableData data] retain];
					[self sdcat:d asciiString:@"A"];
					
					char* userenv = getenv("USER");
					NSString* userstring = [NSString stringWithCString:userenv encoding:NSASCIIStringEncoding];
					
					[d appendData:[self hollerithFromString:[NSString stringWithFormat:@"%@%%%@", userstring, [localhost name]]]];
					[self sdcat:d asciiString:@"\n"];
					[self logData:d];
					[_wdata setData:d];
				}

				
			} else if (connectionState == KOM_HANDSHAKE_RECEIVED) {
				if (byteIndex == [_wdata length]) {
					NSLog(@"resetting send buffer");
					[_wdata setLength:0];
					byteIndex = 0;
				}
			}
			BOOL sent = [self send];
			if (sent && connectionState == KOM_ESTABLISHED) {
				connectionState = KOM_HANDSHAKE_SENT;
			}
			
			break;
		case NSStreamEventOpenCompleted:
			connectionState = KOM_ESTABLISHED;
			NSLog(@"stream %@ is open for business", stream);
			break;
        case NSStreamEventHasBytesAvailable:
        {
			if (connectionState == KOM_HANDSHAKE_SENT) {
				uint8_t buf[1024];
				if (bytesRead == 0) {
					[_rdata setLength:0];
				}
				unsigned int len = 0;
				len = [(NSInputStream *)stream read:buf maxLength:1024];
				if(len) {
					[_rdata appendBytes:(const void *)buf length:len];
					bytesRead = [NSNumber numberWithInt:[bytesRead intValue]+len];
					NSLog(@"I gots datas: %d bytes", len);
					NSMutableData* srvGreeting = [NSMutableData data];
					[srvGreeting setData:[@"LysKOM\n" dataUsingEncoding:NSASCIIStringEncoding]];
					NSLog(@"raw data: %@", _rdata);
					if ([_rdata isEqualToData:srvGreeting]) {
						NSLog(@"LysKOM reply received from server (yay)");
						connectionState = KOM_HANDSHAKE_RECEIVED;
						bytesRead = 0;
						[self login];
						NSLog(@"returned from login");
					}
					
				} else {
					NSLog(@"no buffer!");
				}
			} else if (connectionState == KOM_HANDSHAKE_RECEIVED) {
				uint8_t buf[1024];
				if (bytesRead == 0) [_rdata setLength:0];
				
				unsigned int len = 0;
				len = [iStream read:buf maxLength:1024];
				NSLog(@"Read %d bytes", len);
				if (len) {
					[_rdata appendBytes:(const void*) buf length:len];
					NSLog(@"Received data: %@", _rdata);
					bytesRead = [NSNumber numberWithInt:[bytesRead intValue]+len];
					NSString* string = [[NSString alloc] initWithBytes:[_rdata mutableBytes] length:[bytesRead intValue] encoding:NSISOLatin1StringEncoding];
					NSLog(@"Received (bytesRead: %d): %@", [bytesRead intValue], string);
					
					// get the whole buffer for examination
					unsigned int rlen = [_rdata length];
					uint8_t databuf[rlen];
					BOOL haveAToken = NO;
					[_rdata getBytes:databuf length:rlen];
					// check if we have either a space or a linefeed. That means we have a first
					// token to parse
					for (int i=0; i < rlen; i++) {
						if ((databuf[i] == '\n') || (databuf[i] == ' ')) {
							haveAToken = YES;
						}
					}
					NSLog(@"have a token: %d", haveAToken);
					if (haveAToken) {
						if ((databuf[0] == '%') && (databuf[1] == '%')) {
							NSLog(@"Server says protocol error. We're doing something wrong.");
							[_rdata setLength:0];
							bytesRead = 0;
							return;
						}
						BOOL handled = NO;
						switch (databuf[0]) {
							case '=':
								handled = [self handleRpcReply:YES requestData: _rdata];
								break;
							case '%':
								handled = [self handleRpcReply:NO requestData: _rdata];
								break;
							case ':':
								NSLog(@"Asynchronous message");
								readParseOffset = rlen;
								handled = YES;
								break;
							default:
								NSLog(@"Incomprehensible: %d", databuf[0]);
								handled = YES;
								break;
						}
						if (handled) {
							if (readParseOffset < [_rdata length]-1) {
								NSLog(@"readParseOffset: %d [_rdata length]: %d", readParseOffset, [_rdata length]);
								NSRange r = { readParseOffset, [_rdata length] -  ((NSUInteger) readParseOffset) };
								[_rdata setData:[_rdata subdataWithRange:r]];
								readParseOffset = 0;
								bytesRead = [NSNumber numberWithInt:r.length];
								NSLog(@"Data only partially handled, %d bytes remaining", bytesRead);
							} else {
								[_rdata setLength:0];
								bytesRead = 0;
								NSLog(@"Data handled, clearing buffer.");
							}
						} else {
							NSLog(@"Data not handled, retaining buffer to get more data.");
						}
					} else {
						NSLog(@"incomplete line received");
					}
					
				} else {
					NSLog(@"NSStreamEventHasBytesAvailable but no buffer from input stream %@. Huh?", iStream);
				}
			} else {
				NSLog(@"got bytes but I'm in a state where I don't know what to do.");
			}
            break;
        }
	}
}

// will start reading at readParseOffset, will return nil if the object given doesn't
// have all the data
- (NSString*)readHollerith:(NSData*)data {
	int l0 = [data length];
	
	uint8_t buf[l0];
	(void)memcpy(buf, [data bytes], l0);
	
	int i=++readParseOffset;
	//NSLog(@"readHollerith: initial readParseOffset=%d", readParseOffset);
	while (i < [data length] && (buf[i] >= '0') && (buf[i] <= '9')) { i++; }
	int l = i-readParseOffset;
	//NSLog(@"readHollerith: i=%d, l=%d", i, l);
	NSRange r = { readParseOffset, l };
	uint8_t buf3[l];
	[data getBytes:buf3 range:r];
	NSString* s = [[NSString alloc] initWithBytes:buf3 length:l encoding:NSASCIIStringEncoding];
	//NSLog(@"hollerith length: %@", s);
	NSNumber* num = [[NSDecimalNumber alloc] initWithString:s];
	int length = [num intValue];
	readParseOffset += l+1; // 'H'
	
	if (readParseOffset + length > [data length]) {
		NSLog(@"readHollerith: wanted to read a hollerith of %d bytes but buffer length is %d and readParseOffset is %d", length, [data length], readParseOffset);
		return nil;
	}
	
	uint8_t buf2[length];
	NSRange r2 = { readParseOffset, length };
	[data getBytes:buf2 range:r2];
	// assumes iso-8859-1 for the hollerith contents
	NSString* s2 = [[NSString alloc] initWithBytes:buf2 length:length encoding:NSISOLatin1StringEncoding];
	readParseOffset += length;
	//NSLog(@"readHollerith: %@ readParseOffset=%d", s2, readParseOffset);
	return s2;
}

- (BOOL)handle_get_text:(BOOL)wasSuccessful requestData:(NSData*) data {
	NSLog(@"handle_get_text: readParseOffset=%d", readParseOffset);
	int originalOffset = readParseOffset;
	NSString* text = [self readHollerith:data];
	if (text == nil) {
		NSLog(@"handle_get_text: readHollerith failed");
		// reset the buffer offset so that we can try again later when more
		// data has arrived
		readParseOffset = originalOffset;
		return NO;
	}
	NSLog(@"handle_get_text: string is \"%@\", readParseOffset=%d", text, readParseOffset);
	return YES;
}

- (BOOL)handleRpcReply:(BOOL)wasSuccessful requestData:(NSData*)data {
	int seqno = [self parseRpcNum:data];
	NSLog(@"Handling reply for RPC request #%d (%s)", seqno, wasSuccessful ? "successful" : "failed");
	NSNumber* command = (NSNumber*) [pendingCalls objectForKey:[NSNumber numberWithInt:seqno]];
	BOOL handled = YES;
	if (command) {
		NSLog(@"Found that RPC request %d was a command %d", seqno, [command intValue]);
		int cmd = [command intValue];
		
		switch (cmd) {
			case KOM_login:
				if (wasSuccessful) {
					NSLog(@"Login OK, sending client version");
					[self setClientVersion:@"Komkaw Cocoa OS X" version:@"0.0"];
					NSLog(@"Client version sent, asking for a text");
					[self getText:76232];
				} else {
					NSLog(@"Login failed!");
				}
				break;
			case KOM_get_text:
				handled = [self handle_get_text:wasSuccessful requestData:data];
				break;
			default:
				break;
		}
	} else {
		NSLog(@"Did not find a corresponding command for request %d", seqno);
	}
	if (handled) {
		[pendingCalls removeObjectForKey:[NSNumber numberWithInt:seqno]];
	}
	
	return handled;	
}

- (int)parseRpcNum:(NSData *) data {
	NSLog(@"attempting to parse data string %@", data);
	int blen = [data length];
	if (blen == 0) {
		NSLog(@"parseRpcNum called with empty NSData object, what's up with that?");
		return 0;
	}
	uint8_t buf[blen];
	[data getBytes:buf length:blen];
	int offset = [data length] - 1;
	for (int i=1; i < [data length]; i++) {
		if ((buf[i] == ' ') || (buf[i] == '\n')) {
			offset = i;
			break;
		}
	}
	uint8_t buf2[offset];
	NSRange r = {1, offset};
	readParseOffset = offset;
	[data getBytes:buf2 range:r];
	NSString* str = [[NSString alloc] initWithBytes:buf2 length:offset encoding:NSASCIIStringEncoding];
	NSNumber* num = [[NSDecimalNumber alloc] initWithString:str];
	NSLog(@"parsed, readParseOffset=%d.", readParseOffset);
	
	return [num intValue];
}

@end
