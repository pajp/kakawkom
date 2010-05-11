//
//  KomArray.h
//  KakawKOM
//
//  Created by Rasmus Sten on 2010-05-08.
//  Copyright 2010 Bricole. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KomToken.h"
#import "KomInt.h"

@interface KomArray : KomToken {
	int arrayLength;
	NSArray* array;
}
+(KomArray*)arrayFromArray:(NSArray *)a;
-(void)setArray:(NSArray*)a;
-(void)setArrayLength:(int)l;
@end
