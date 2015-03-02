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
#define ACCURACY_TOLERANCE 100.0

#define BEGIN_UPDATE_LOCATION_EVERY_N_SECONDS 15.0
#define UPDATE_LOCATION_FOR_N_SECONDS 2.0

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic) CLLocationAccuracy currentLocationAccuracy;

+ (instancetype) sharedLocationTracker;

- (void) startLocationTracking;
- (void) stopLocationTracking;
- (void) saveLocation;


@end
