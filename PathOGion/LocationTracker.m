//
//  LocationTracker.m
//  Location
//
//  Created by Ricky Chea
//  Copyright (c) 2014 Location. All rights reserved.
//
//  Edited by Simon Ayzman
//  Copyright (c) 2015 PathOGion. All rights reserved.

#import "LocationTracker.h"
#import "CoreDataLocationPoint.h"
#import "AppDelegate.h"
#import "BackgroundTaskManager.h"
#import "LocationPoint.h"

#define COORDINATE @"user_coordinate"
#define LATITUDE @"user_latitude"
#define LONGITUDE @"user_longitude"
#define ACCURACY @"user_location_accuracy"
#define TIMESTAMP @"user_location_timestamp"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface LocationTracker()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) LocationPoint *lastLocation;
@property (nonatomic) NSTimer *refreshBackgroundTimer;
@property (nonatomic) BackgroundTaskManager *bgTask;

@end

@implementation LocationTracker

+ (instancetype) sharedLocationTracker
{
    static id _sharedLocationTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLocationTracker = [[self alloc] init];
    });
    return _sharedLocationTracker;
}

- (instancetype) init
{
    if (self = [super init])
    {
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

- (CLLocationManager *) locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //_locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.distanceFilter = DISTANCE_FILTER;
        _locationManager.pausesLocationUpdatesAutomatically = YES;
    }
	return _locationManager;
}

- (LocationPoint *) currentLocation
{
    if (!_currentLocation)
        _currentLocation = [[LocationPoint alloc]init];
    return _currentLocation;
}

- (LocationPoint *) lastLocation
{
    if (!_lastLocation)
        _lastLocation = [[LocationPoint alloc]init];
    return _lastLocation;
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
    
    self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
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
    NSLog(@"locationManager didUpdateLocations");
    
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
        else if (locationAccurary > ACCURACY_TOLERANCE)
            NSLog(@"Location accuracy is too low.");
        else
        {
            self.lastLocation.latitude = self.currentLocation.latitude;
            self.lastLocation.longitude = self.currentLocation.longitude;
            self.lastLocation.accuracy = self.currentLocation.accuracy;
            self.lastLocation.timestamp = self.currentLocation.timestamp;

            self.currentLocation.latitude = locationCoordinate.latitude;
            self.currentLocation.longitude = locationCoordinate.longitude;
            self.currentLocation.accuracy = locationAccurary;
            self.currentLocation.timestamp = location.timestamp;

            [self saveLocation:self.currentLocation];
        }
    }

    self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
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

// Send the location to Server
- (void) saveLocation: (LocationPoint *) location
{
    NSLog(@"savingLocation");
    
    NSLog(@"Saving: (%f, %f) within %+.2f meters. Timestamp: %@.", location.latitude, location.longitude, location.accuracy, location.timestamp);

    // Saving to Core Data

    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = app.managedObjectContext;

    CoreDataLocationPoint *coreDataLocationPoint = [NSEntityDescription insertNewObjectForEntityForName:@"CoreDataLocationPoint"
                                                                         inManagedObjectContext:managedObjectContext];
    coreDataLocationPoint.latitude = location.latitude;
    coreDataLocationPoint.longitude = location.longitude;
    coreDataLocationPoint.accuracy = location.accuracy;
    coreDataLocationPoint.timestamp = location.timestamp;
    [app saveContext];
    
}

- (void) printAllSavedLocations
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = app.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CoreDataLocationPoint"];
    [request setReturnsObjectsAsFaults:NO];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    NSError *error;
    NSArray *coreDataLocationPoints = [managedObjectContext executeFetchRequest:request error:&error];
    if (error)
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    else
    {
        for (CoreDataLocationPoint *location in coreDataLocationPoints)
            NSLog(@"[%@]: (%f, %f) within %.2f meters.", location.timestamp, location.latitude, location.longitude, location.accuracy);
    }
}

- (void) deleteAllSavedLocations
{
    NSLog(@"deleteAllSavedLocations");

    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = app.managedObjectContext;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CoreDataLocationPoint"];
    [request setReturnsObjectsAsFaults:NO];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    NSError *error;
    NSArray *coreDataLocationPoints = [managedObjectContext executeFetchRequest:request error:&error];
    if (error)
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    else
    {
        for (CoreDataLocationPoint *location in coreDataLocationPoints)
             [managedObjectContext deleteObject:location];
    }
    [app saveContext];
}

@end
