//
//  POGLocationPath.m
//  PathOGion
//
//  Created by Simon Ayzman on 4/2/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import "POGLocationPath.h"
#import "POGLocationPoint.h"

@interface POGLocationPath()

@property (strong, nonatomic) NSMutableArray *locationPath;

@end

@implementation POGLocationPath

- (NSMutableArray *) locationPath
{
    if (!_locationPath)
        _locationPath = [[NSMutableArray alloc] init];
    return _locationPath;
}

- (instancetype) init
{
    return [self initWithLocationPoints:nil];
}

- (instancetype) initWithLocationPoints: (NSArray *) locationPoints
{
    if (self = [self init])
    {
        [self addLocationPoints:locationPoints];
    }
    return self;
}

- (void) addLocationPoint: (POGLocationPoint *) locationPoint
{
    
}

- (void) addLocationPoints: (NSArray *) locationPoints
{
    if (locationPoints)
    {
        NSArray *temp = [locationPoints sortedArrayUsingDescriptors:@[[POGLocationPoint locationPointSortDescriptor]]];
        self.locationPath = [temp mutableCopy];
    }
}

- (NSArray *) getLocationPath
{
    return [self.locationPath copy];
}

@end
