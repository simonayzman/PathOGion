//
//  POGLocationPoint.m
//  PathOGion
//
//  Created by Simon Ayzman on 3/19/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import "POGLocationPoint.h"
#import "POGCoreDataLocationPoint.h"

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

- (instancetype) initWithCoreDataLocationPoint:(POGCoreDataLocationPoint *)coreDataLocationPoint
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

+ (NSSortDescriptor *) locationPointSortDescriptor
{
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO comparator:^(id loc1, id loc2) {
        NSLog(@"Comparing two locationPoints \n%@\nand\n%@", loc1, loc2);
        if (((POGLocationPoint *)loc1).timestamp > ((POGLocationPoint *)loc2).timestamp) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (((POGLocationPoint *)loc1).timestamp < ((POGLocationPoint *)loc2).timestamp) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
                            
    return sd;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%f, %f) within %+.2f meters. Timestamp: %@.", self.latitude, self.longitude, self.accuracy, self.timestamp];
}

@end

