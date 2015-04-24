//
//  POGLocationTracker.m
//  PathOGion
//
//  Created by Ricky Chea
//  Copyright (c) 2014 Location. All rights reserved.
//
//  Edited by Simon Ayzman
//  Copyright (c) 2015 PathOGion. All rights reserved.

#import "POGLocationTracker.h"
#import "POGCoreDataLocationPoint.h"
#import "POGBackgroundTaskManager.h"
#import "POGLocationPoint.h"
#import "POGCoreDataManager.h"
#import "CLLocation+measuring.h"

#define COORDINATE @"user_coordinate"
#define LATITUDE @"user_latitude"
#define LONGITUDE @"user_longitude"
#define ACCURACY @"user_location_accuracy"
#define TIMESTAMP @"user_location_timestamp"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface POGLocationTracker()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) POGLocationPoint *previousLocation;
@property (strong, nonatomic) NSTimer *refreshBackgroundTimer;
@property (strong, nonatomic) POGBackgroundTaskManager *bgTask;
@property (weak, nonatomic) POGCoreDataManager *coreDataManager;
@property (assign, nonatomic) double distanceFilter;

@end

@implementation POGLocationTracker

+ (instancetype) sharedLocationTracker
{
    static id _sharedLocationTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLocationTracker = [[self alloc] initPrivate];
    });
    return _sharedLocationTracker;
}

- (instancetype) initPrivate
{
    if (self = [super init])
    {
        _distanceFilter = DISTANCE_FILTER;
        _coreDataManager = [POGCoreDataManager sharedCoreDataManager];
        _currentLocation = [[POGLocationPoint alloc] initWithCoreDataLocationPoint:[_coreDataManager mostRecentSavedCoreDataLocationPoint]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (instancetype) init
{
    NSLog(@"Cannot use init with singleton class POGLocationTracker.");
    abort();
    return nil;
}

- (CLLocationManager *) locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = self.distanceFilter;
        _locationManager.pausesLocationUpdatesAutomatically = YES;
    }
	return _locationManager;
}

- (POGLocationPoint *) currentLocation
{
    if (!_currentLocation)
        _currentLocation = [[POGLocationPoint alloc]init];
    return _currentLocation;
}

- (POGLocationPoint *) previousLocation
{
    if (!_previousLocation)
        _previousLocation = [[POGLocationPoint alloc]init];
    return _previousLocation;
}

// This function is called whenever LocationTracker receives a
// notification that the application has gone into the background
- (void) applicationDidEnterBackground: (NSNotification *) notification
{
    NSLog(@"applicationDidEnterBackground in LocationTracker");

    if(IS_OS_8_OR_LATER)
        [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
    
    self.refreshBackgroundTimer = [NSTimer scheduledTimerWithTimeInterval:120
                                                                   target:self
                                                                 selector:@selector(remainInBackground)
                                                                 userInfo:nil
                                                                  repeats:YES];
    
    self.bgTask = [POGBackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];
}

// This function is called whenever LocationTracker receives a
// notification that the application has finished launching
- (void) applicationDidFinishLaunching: (NSNotification *) notification
{
    NSLog(@"applicationDidFinishLaunching in LocationTracker");
    if (self.refreshBackgroundTimer)
    {
        [self.refreshBackgroundTimer invalidate];
        self.refreshBackgroundTimer = nil;
    }
}

- (void) remainInBackground
{
    NSLog(@"remainInBackground");
    
    if(IS_OS_8_OR_LATER)
        [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
}


- (void) startLocationTracking
{
    NSLog(@"startLocationTracking");

    if ([CLLocationManager locationServicesEnabled])
    {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted)
            NSLog(@"authorizationStatus failed");
        else
        {
            if(IS_OS_8_OR_LATER)
              [self.locationManager requestAlwaysAuthorization];
            [self.locationManager startUpdatingLocation];
        }
	}
    else
    {
        NSLog(@"locationServicesEnabled false");
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}


- (void) stopLocationTracking
{
    NSLog(@"stopLocationTracking");
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"locationManager didUpdateLocations (%lu locations)", locations.count);
    
    for (int i=0; i<locations.count; i++)
    {
        CLLocation *location = [locations objectAtIndex:i];
        CLLocationCoordinate2D locationCoordinate = location.coordinate;
        CLLocationAccuracy locationAccurary = location.horizontalAccuracy;
        
        //Select only valid location with good accuracy
        if(!location)
            NSLog(@"Location is not valid.");
        else if (locationCoordinate.latitude == 0.0 && locationCoordinate.longitude == 0.0)
            NSLog(@"Location may not be valid.");
        else if (locationAccurary <= 0)
            NSLog(@"Location accuracy is not valid.");
        else if (locationAccurary > SAVE_TOLERANCE)
            NSLog(@"Location accuracy is too low.");
        else if ([CLLocation distanceFromCoordinate:locationCoordinate
                                       toCoordinate:[self.currentLocation CLLocationCoordinate2D]] < self.distanceFilter)
            NSLog(@"Location is too close to the most recently saved location.");
        else
        {
            self.previousLocation.latitude = self.currentLocation.latitude;
            self.previousLocation.longitude = self.currentLocation.longitude;
            self.previousLocation.accuracy = self.currentLocation.accuracy;
            self.previousLocation.timestamp = self.currentLocation.timestamp;

            self.currentLocation.latitude = locationCoordinate.latitude;
            self.currentLocation.longitude = locationCoordinate.longitude;
            self.currentLocation.accuracy = locationAccurary;
            self.currentLocation.timestamp = location.timestamp;

            [self saveLocationPoint:self.currentLocation];
        }
        //[self updateDistanceFilterForDeviceSpeed:location.speed];
    }
    
    self.bgTask = [POGBackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];
}

- (void) locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    NSLog(@"locationManager didFailWithError:%@",error);
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        case kCLErrorDenied:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"locationManager didChangeAuthorizationStatus:%d", status);
}

- (void) saveLocationPoint: (POGLocationPoint *) locationPoint
{
    NSLog(@"savingLocation: %@.", locationPoint);
    [self.coreDataManager saveLocationPointToCoreData:locationPoint];
}

#pragma mark - Distance Filter mechanics

- (void) updateDistanceFilterForDeviceSpeed: (double) speed
{
    // For every 15mph above 10mph, m, the distance
    // filter is (m x .5) times greater than 40 meters
    double adjustedSpeed = (fabs(speed - 0) < 0.01f) ? 0 : fabs(speed);
    double currentSpeedInMPH = adjustedSpeed * 2.23694;
    double newDistanceFilter = (currentSpeedInMPH <= 10) ? 40.f : 40.f * (1 + 0.5f * ceil(((currentSpeedInMPH - 10) / 15)));
    if (fabs(self.distanceFilter - newDistanceFilter) < 0.01f)
    {
        self.distanceFilter = newDistanceFilter;
        self.locationManager.distanceFilter = self.distanceFilter;
        NSLog(@"New distanceFilter: %f meters", self.distanceFilter);
    }
}

@end
