//
//  GHSlowTest.m
//  GRUnit
//
//  Created by Gabriel Handford on 1/24/09.
//  Copyright 2009. All rights reserved.
//

#import "GRTestCase.h"

@interface GRSlowTest : GRTestCase { }
@end


@implementation GRSlowTest

- (void)test2Seconds {
  [NSThread sleepForTimeInterval:2];
}

@end
