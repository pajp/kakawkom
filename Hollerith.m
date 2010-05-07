//
//  Hollerith.m
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-07.
//  Copyright 2010 Bricole. All rights reserved.
//

#import "Hollerith.h"


@implementation Hollerith

- (id) init {
	self = [super init];
	return self;
}

+ (Hollerith*)hollerithFromString:(NSString *) string {
	//NSLog(@"hollerithFromString:string=%@", string);
	NSMutableData* _d = [[NSMutableData data] retain];
	Hollerith* h = [[Hollerith alloc] initWithData:_d];
	// convert to iso-8859-1 string
	NSMutableData* s = [[NSMutableData data] retain];
	[s setData:[string dataUsingEncoding:NSISOLatin1StringEncoding]];
	NSString* lstr = [NSString stringWithFormat:@"%dH", [s length]];
	NSData* lstrdata = [lstr dataUsingEncoding:NSASCIIStringEncoding];
	[_d appendBytes:[lstrdata bytes] length:[lstrdata length]];
	[_d appendBytes:[s bytes] length:[s length]];
	return h;
}
// will start reading at offset, will return nil if the object given doesn't
// have all the data
+ (Hollerith*)hollerithFromData:(NSData*)data offset:(int)readParseOffset {
	int l0 = [data length];
	uint8_t buf[l0];
	(void)memcpy(buf, [data bytes], l0);
	
	int readParseStart = readParseOffset;
	int i=readParseOffset;
	NSLog(@"readHollerith: initial readParseOffset=%d", readParseOffset);
	while (i < [data length] && (buf[i] >= '0') && (buf[i] <= '9')) { i++; }
	int l = i-readParseOffset;
	NSLog(@"readHollerith: i=%d, l=%d", i, l);
	NSRange r = { readParseOffset, l };
	uint8_t buf3[l];
	[data getBytes:buf3 range:r];
	NSString* s = [[NSString alloc] initWithBytes:buf3 length:l encoding:NSASCIIStringEncoding];
	NSLog(@"hollerith length: %@", s);
	NSNumber* num = [[NSDecimalNumber alloc] initWithString:s];
	int length = [num intValue];
	readParseOffset += l+1; // 'H'
	
	if (readParseOffset + length > [data length]) {
		NSLog(@"readHollerith: wanted to read a hollerith of %d bytes but buffer length is %d and readParseOffset is %d", length, [data length], readParseOffset);
		return nil;
	}
	
	NSRange hollerithRange = { readParseStart, length+r.length+1 };
	NSMutableData* holldata = [[NSMutableData data] retain];
	[holldata setData:[data subdataWithRange:hollerithRange]];
	Hollerith* h = [[Hollerith alloc] initWithData:holldata];
	NSLog(@"readHollerith: hollerith data: %@", holldata);
	NSLog(@"readHollerith: hollerith data: %@", [[NSString alloc] initWithData:holldata encoding:NSISOLatin1StringEncoding]);
	[h setLengthRange:r];
	
	NSRange r2 = { l+1, length };
	[h setContentRange:r2];
	return h;
	
}


- (void) setLengthRange:(NSRange)r {
	lengthRange = r;
}

- (void) setContentRange:(NSRange)r {
	contentRange = r;
}


- (NSString*) string {
	NSLog(@"Hollerith string");
	uint8_t buf2[contentRange.length];
	[data getBytes:buf2 range:contentRange];
	// assumes iso-8859-1 for the hollerith contents
	NSString* s2 = [[NSString alloc] initWithBytes:buf2 length:contentRange.length encoding:NSISOLatin1StringEncoding];
	//NSLog(@"readHollerith: %@ readParseOffset=%d", s2, readParseOffset);
	return s2;
}


@end
