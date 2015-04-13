//
//  POGLocationTracker.h
//  PathOGion
//
//  Created by Ricky Chea
//  Copyright (c) 2014 Location. All rights reserved.
//
//  Edited by Simon Ayzman
//  Copyright (c) 2015 PathOGion. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class POGLocationPoint;

#define DISTANCE_FILTER 40.0
#define ACCURACY_TOLERANCE 100.0
#define SAVE_TOLERANCE 500.0

@interface POGLocationTracker : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) POGLocationPoint *currentLocation;

+ (instancetype) sharedLocationTracker;

- (void) startLocationTracking;
- (void) stopLocationTracking;

@end
