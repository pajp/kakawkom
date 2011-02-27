//
//  KakawKom.h
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-07.
//  Copyright 2010 Bricole. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "Hollerith.h"
#include "KomArray.h"
#include "KomInt.h"

// status of the protocol
#define KOM_DISCONNECTED		0
#define KOM_ESTABLISHED			1
#define KOM_HANDSHAKE_SENT		2
#define KOM_HANDSHAKE_RECEIVED	3
// status of the session
#define KOM_CONNECTED			1
#define KOM_LOGGED_IN			2

#define KOM_get_text			25
#define KOM_login				62
#define KOM_set_client_version	69
#define KOM_accept_async		80

#define KOM_async_send_message	12



@interface KakawKom : NSObject <NSStreamDelegate> {
	
	NSInputStream* iStream;
	NSOutputStream* oStream;
	NSMutableData* _rdata;
	NSMutableData* _wdata;
	
	// a dictionary mapping RPC call numbers to protocol requests
	// calls are removed when they have been handled
	NSMutableDictionary* pendingCalls;
	
	NSNumber* bytesRead;
    int userId;
    NSString* password;
    BOOL loggedIn;
	
	int eventCount;
	
	int connectionState;
	int sessionState;
	// readParseOffset up until which data in the buffer has already been read (and acted upon)
	int readParseOffset;
	int byteIndex;
	int callSequence;
	int loginSeqNo;
	BOOL canWrite;
}

@property BOOL loggedIn;
@property (assign) int userId;
@property (assign) NSString* password;

- (void)login;
- (BOOL)send;
- (void)logData:(NSData *)data;
- (int)rpcSend:(int)call parameters:(NSData*)parameters;
- (int)parseRpcNum:(NSData *) data;
- (BOOL)handleRpcReply:(BOOL)result requestData:(NSData*)data;
- (BOOL)handleAsyncMessage:(NSData *)data;
- (void)separator:(NSData *)data;
- (void)sdcat:(NSMutableData *)data asciiString:(NSString *)string;
- (void)treatReadBuffer;

@end
