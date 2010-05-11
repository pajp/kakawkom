//
//  KomInt.m
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-08.
//  Copyright 2010 Bricole. All rights reserved.
//

#import "KomInt.h"


@implementation KomInt

+ (KomInt*) intFromInt:(int)value {
	KomInt* k = [KomInt new];
	[k setData:[[NSString stringWithFormat:@"%d", value] dataUsingEncoding:NSASCIIStringEncoding]];
	return k;
}

+ (KomInt*) intFromData:(NSData*)data offset:(int)offset {
	KomToken* t = [KomToken tokenFromData:data readOffset:offset];
	KomInt* k = [KomInt new];
	[k setData:[t data]];
	return k;
}

- (int) intValue {
	NSString* s = [[NSString alloc] initWithBytes:[[self data] bytes] length:[[self data] length] encoding:NSASCIIStringEncoding];
	NSNumber* n = [[NSDecimalNumber alloc] initWithString:s];
	int i = [n intValue];
	NSLog(@"intValue: s: %@ n: %@ i: %d", s, n, i);
	[n release];
	[s release];	
	return i;
}
	 

@end
