//
//  KomToken.m
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-07.
//  Copyright 2010 Bricole. All rights reserved.
//

#import "KomToken.h"


@implementation KomToken

+ (KomToken*)tokenFromData:(NSData*) data readOffset:(int)offset {
	NSLog(@"[KomToken tokenFromData] '%@' offset: %d", [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding], offset);
	uint8_t buf[[data length]];
	memcpy(buf, [data bytes], [data length]);
	int i=offset;
	while (i < [data length] && (buf[i] != ' ') && (buf[i] != '\n')) i++;
	NSLog(@"i=%d", i);
	if (i > [data length]) {
		NSLog(@"KomToken tokenFromData: did not find a token terminator, returning nil");
		return nil;
	}
	
	NSRange tokenRange = { offset, i-offset };
	NSLog(@"range: %d, %d", offset, i-offset);
	KomToken* t = [[KomToken alloc] initWithData:[data subdataWithRange:tokenRange]];
	return t;
}

// init this KomToken, backed by an NSMutableData object
- (id) init {
	self = [super init];
	data = [NSMutableData data];
	return self;
}

// initialize this KomToken, backed by the specified data object
- (id) initWithData:(NSData*) d {
	self = [super init];
	data = d;
	return self;
}

- (NSData*) data {
	return data;
}

- (void) setData:(NSData*)d {
	data = d;
}

- (int) length {
	return [data length];
}





@end
