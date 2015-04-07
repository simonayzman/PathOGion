//
//  LocationTracker.h
//  Location
//
//  Created by Ricky Chea
//  Copyright (c) 2014 Location. All rights reserved.
//
//  Edited by Simon Ayzman
//  Copyright (c) 2015 PathOGion. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class POGLocationPoint;

#define DISTANCE_FILTER 100.0
#define ACCURACY_TOLERANCE 100.0

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) POGLocationPoint *currentLocation;

+ (instancetype) sharedLocationTracker;

- (void) startLocationTracking;
- (void) stopLocationTracking;

- (void) saveLocation: (POGLocationPoint *) location;
- (void) printAllSavedLocations;
- (void) deleteAllSavedLocations;

@end
