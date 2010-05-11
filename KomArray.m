//
//  KomArray.m
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-08.
//  Copyright 2010 Bricole. All rights reserved.
//

#import "KomArray.h"


@implementation KomArray

// reads an array from the server, assuming that it consists only of types
// that does not contain any spaces
+ (KomArray*)arrayFromData:(NSData*)data offset:(int)offset {
	int startOffset = offset;
	KomInt* lengthToken = (KomInt*) [KomInt tokenFromData:data readOffset:offset];
	int arrayLength = [lengthToken intValue];
	offset += [[lengthToken data] length];
	offset++; // ' '
	KomToken* start = [KomToken tokenFromData:data readOffset:offset];
	NSData* sdata = [start data];
	offset++;
	uint8_t buf[[sdata length]];
	memcpy(buf, [sdata bytes], [sdata length]);
	
	if (buf[0] == '*') {
		// empty or length-informative array
		KomArray* k = [KomArray new];
		[k setData:[data subdataWithRange:NSMakeRange(startOffset, offset-startOffset)]];
		[k setArrayLength:arrayLength];
		return k;
	}
	
	
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:arrayLength];
	for (int i=0; i < arrayLength; i++) {
		KomToken* t = [KomToken tokenFromData:data readOffset:offset];
		[array addObject:t];
		offset += [[t data] length] + 1;
	}
		
	KomArray* k = [[KomArray alloc] init];
	[k setArrayLength:arrayLength];
	[k setArray:array];
	[k setData:[data subdataWithRange:NSMakeRange(startOffset, offset-startOffset)]];
	return k;
	
}

+ (KomArray*)arrayFromArray:(NSArray*)a {
	NSMutableData* prefix = [NSMutableData new];
	NSData* suffix = [@"}" dataUsingEncoding:NSASCIIStringEncoding];
	NSMutableData* d = [NSMutableData new];
	[d retain];
	uint8_t _space[] = { ' ' };
	NSData* space = [NSData dataWithBytes:_space length:1];
	
	[prefix setData:[[NSString stringWithFormat:@"%d { ", [a count]] dataUsingEncoding:NSASCIIStringEncoding]];
	[d appendData:prefix];
	
	for (KomToken* token in a) {
		[d appendData:[token data]];
		[d appendData:space];
	}
	[d appendData:suffix];
	KomArray* k = [KomArray new];
	[k setData:d];
	[k setArray:a];
	[k setArrayLength:[a count]];

	return k;
}

- (void) setArray:(NSArray*) a {
	array = a;
	arrayLength = [a count];
}

- (void) setArrayLength:(int)l {
	arrayLength = l;
}
- (int) arrayLength {
	return arrayLength;
}

- (NSArray*) array {
	return array;
}
@end
