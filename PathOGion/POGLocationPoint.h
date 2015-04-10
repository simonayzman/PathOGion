//
//  POGLocationPoint.h
//  PathOGion
//
//  Created by Simon Ayzman on 3/19/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/Mapkit.h"

@class POGCoreDataLocationPoint;

@interface POGLocationPoint : NSObject

@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) double accuracy;
@property (strong, nonatomic) NSDate *timestamp;

// Designated initializer
- (instancetype) initWithLatitude:(double)latitude longitude:(double)longitude accuracy:(double)accuracy timestamp:(NSDate *)timestamp;
- (instancetype) initWithCoreDataLocationPoint:(POGCoreDataLocationPoint *)coreDataLocationPoint;

- (CLLocationCoordinate2D) CLLocationCoordinate2D;

+ (NSSortDescriptor *) locationPointSortDescriptor;
+ (NSComparisonResult (^) (id,id))locationPointComparatorBlock;
+ (NSArray *) locationPointsFromCoreDataLocationPoints: (NSArray *) coreDataLocationPoints;

@end