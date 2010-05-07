//
//  KomToken.m
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-07.
//  Copyright 2010 Bricole. All rights reserved.
//

#import "KomToken.h"


@implementation KomToken

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




@end
