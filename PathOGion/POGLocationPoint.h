//
//  POGLocationPoint.h
//  PathOGion
//
//  Created by Simon Ayzman on 3/19/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
@class POGCoreDataLocationPoint;

@interface POGLocationPoint : NSObject

@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) double accuracy;
@property (strong, nonatomic) NSDate *timestamp;

- (instancetype) initWithCoreDataLocationPoint:(POGCoreDataLocationPoint *)coreDataLocationPoint;

+ (NSSortDescriptor *) locationPointSortDescriptor;

@end