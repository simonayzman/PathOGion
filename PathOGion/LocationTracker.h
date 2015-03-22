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
#import "BackgroundTaskManager.h"

#define DISTANCE_FILTER 10.0
#define ACCURACY_TOLERANCE 100.0

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) NSDictionary *currentLocation;

+ (instancetype) sharedLocationTracker;

- (void) startLocationTracking;
- (void) stopLocationTracking;
- (void) saveLocation: (NSDictionary *) location;
- (void) deleteLocations;

@end
