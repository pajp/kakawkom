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
+ (KomToken*)tokenFromData:(NSData*) data readOffset:(int)offset;
- (id) initWithData:(NSData*)d;
- (NSData*) data;
- (void) setData:(NSData *)d;
- (int) length;
@end
