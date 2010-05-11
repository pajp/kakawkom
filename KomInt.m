//
//  KomInt.m
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-08.
//  Copyright 2010 Bricole. All rights reserved.
//

#import "KomInt.h"


@implementation KomInt


- (int) intValue {
	NSString* s = [[NSString alloc] initWithBytes:[[self data] bytes] length:[[self data] length] encoding:NSASCIIStringEncoding];
	NSNumber* n = [[NSDecimalNumber alloc] initWithString:s];
	int i = [n intValue];
	[n release];
	[s release];	
	return i;
}
	 

@end
