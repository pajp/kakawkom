//
//  KomToken.m
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-07.
//  Copyright 2010 Bricole. All rights reserved.
//

#import "KomToken.h"


@implementation KomToken

- (id) init {
	self = [super init];
	data = [NSMutableData data];
	return self;
}

- (id) initWithData:(NSData*) d {
	self = [super init];
	data = d;
	return self;
}

- (NSData*) data {
	return data;
}




@end
