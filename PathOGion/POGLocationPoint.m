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

- (instancetype) initWithLatitude:(double)latitude
                        longitude:(double)longitude
                         accuracy:(double)accuracy
                        timestamp:(NSDate *)timestamp
{
    if (self = [super init])
    {
        self.latitude = latitude;
        self.longitude = longitude;
        self.accuracy = accuracy;
        self.timestamp = timestamp;
    }
    return self;
}

- (instancetype) init
{
    return [self initWithLatitude:0.f
                        longitude:0.f
                         accuracy:0.f
                        timestamp:[NSDate date]];
}

- (instancetype) initWithCoreDataLocationPoint:(POGCoreDataLocationPoint *)coreDataLocationPoint
{
    return [self initWithLatitude:coreDataLocationPoint.latitude
                        longitude:coreDataLocationPoint.longitude
                         accuracy:coreDataLocationPoint.accuracy
                        timestamp:coreDataLocationPoint.timestamp];
}

- (CLLocationCoordinate2D) CLLocationCoordinate2D
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

+ (NSSortDescriptor *) locationPointSortDescriptor
{
    return [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
}

+ (NSComparisonResult (^) (id,id))locationPointComparatorBlock
{
    return ^(id loc1, id loc2) {
        NSLog(@"Comparing two locationPoints \n%@\nand\n%@", loc1, loc2);
        if (((POGLocationPoint *)loc1).timestamp > ((POGLocationPoint *)loc2).timestamp) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (((POGLocationPoint *)loc1).timestamp < ((POGLocationPoint *)loc2).timestamp) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
}

+ (NSArray *) locationPointsFromCoreDataLocationPoints: (NSArray *) coreDataLocationPoints
{
    NSMutableArray *locationPoints = [[NSMutableArray alloc] init];
    for(POGCoreDataLocationPoint *coreDataLocationPoint in coreDataLocationPoints)
    {
        [locationPoints addObject:[[POGLocationPoint alloc] initWithCoreDataLocationPoint:coreDataLocationPoint]];
    }
    return [locationPoints copy];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"(%f, %f) within %+.2f meters. Timestamp: %@.", self.latitude, self.longitude, self.accuracy, self.timestamp];
}

@end

