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
#define ACCURACY_TOLERANCE 50.0

#define BEGIN_UPDATE_LOCATION_EVERY_N_SECONDS 10.0
#define UPDATE_LOCATION_FOR_N_SECONDS 1.0

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) NSDictionary *currentLocation;

+ (instancetype) sharedLocationTracker;

- (void) startLocationTracking;
- (void) stopLocationTracking;
- (void) saveLocation: (NSDictionary *) location;

@end
