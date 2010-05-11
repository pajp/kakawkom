//
//  KomInt.h
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-08.
//  Copyright 2010 Bricole. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KomToken.h"


@interface KomInt : KomToken {
}
+ (KomInt*) intFromInt:(int)value;
+ (KomInt*) intFromData:(NSData *)data offset:(int)offset;
- (int) intValue;

@end
