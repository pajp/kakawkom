//
//  KakTest.m
//  KakTest
//
//  Created by Rasmus Sten on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <unistd.h>

#import "KakTest.h"
#import "KakawKom.h"

@implementation KakTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testConnection {
    KakawKom* kom = [[KakawKom alloc] init];
    kom.userId = 7914;
    char* password = getenv("KOMPASSWORD");
    kom.password = [NSString stringWithCString:password encoding:NSASCIIStringEncoding];
    [kom login];
    //int count = 0;
    // Dragons be here:
    while (!kom.loggedIn) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    STAssertTrue(kom.loggedIn, @"session not logged in after login");
}

@end
