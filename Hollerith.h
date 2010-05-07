//
//  Hollerith.h
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-07.
//  Copyright 2010 Bricole. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KomToken.h"

@interface Hollerith : KomToken {
	NSRange lengthRange;
	NSRange contentRange;
}
+ (Hollerith*) hollerithFromString:(NSString *)string;
+ (Hollerith*) hollerithFromData:(NSData*)data offset:(int)readParseOffset;
- (void) setLengthRange:(NSRange)r;
- (void) setContentRange:(NSRange)r;
- (NSString*) string;
@end
