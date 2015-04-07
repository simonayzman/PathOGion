//
//  POGLocationPoint.m
//  PathOGion
//
//  Created by Simon Ayzman on 3/19/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import "POGLocationPoint.h"
#import "CoreDataLocationPoint.h"

@implementation POGLocationPoint

- (instancetype) init
{
    if (self = [super init])
    {
        self.latitude = 0;
        self.longitude = 0;
        self.accuracy = 0;
        self.timestamp = [NSDate date];
    }
    return self;
}

- (instancetype) initWithCoreDataLocationPoint:(CoreDataLocationPoint *)coreDataLocationPoint
{
    if (self = [super init])
    {
        self.latitude = coreDataLocationPoint.latitude;
        self.longitude = coreDataLocationPoint.longitude;
        self.accuracy = coreDataLocationPoint.accuracy;
        self.timestamp = coreDataLocationPoint.timestamp;
    }
    return self;
}

@end

