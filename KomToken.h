//
//  KomToken.h
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-07.
//  Copyright 2010 Bricole. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KomToken : NSObject {
	NSData* data;
}

- (id) initWithData:(NSData*)d;
- (NSData*) data;

@end
