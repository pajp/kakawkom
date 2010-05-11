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
+ (KomArray*)tokenFromData:(NSData*)data offset:(int)offset {
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
		// empty of length-informative array
		return (KomArray*) [KomToken tokenFromData:[data subdataWithRange:NSMakeRange(startOffset, offset-startOffset)] readOffset:0];
	}
	
	
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:arrayLength];
	for (int i=0; i < arrayLength; i++) {
		KomToken* t = [KomToken tokenFromData:data readOffset:offset];
		[array addObject:t];
		offset += [[t data] length] + 1;
	}
	
	
	KomArray* k = (KomArray*) [super tokenFromData:[data subdataWithRange:NSMakeRange(startOffset, offset-startOffset)] readOffset:0];
	[k setArray:array];
	return k;
	
}

- (void) setArray:(NSArray*) a {
	array = a;
	arrayLength = [a count];
}

- (int) arrayLength {
	return arrayLength;
}

- (NSArray*) array {
	return array;
}
@end
