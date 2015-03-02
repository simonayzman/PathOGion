//
//  LocationTracker.m
//  Location
//
//  Created by Ricky Chea
//  Copyright (c) 2014 Location All rights reserved.
//

#import "LocationTracker.h"

#define COORDINATE @"user_coordinate"
#define LATITUDE @"user_latitude"
#define LONGITUDE @"user_longitude"
#define ACCURACY @"user_location_accuracy"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface LocationTracker()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *savedLocationsArray; // Temporary array to figure out best location
@property (nonatomic) CLLocationCoordinate2D lastLocationCoordinate;
@property (nonatomic) CLLocationAccuracy lastLocationAccuracy;

@property (nonatomic) NSTimer *beginUpdateLocationEveryNSecondsTimer;
@property (nonatomic) NSTimer *updateLocationForNSecondsTimer;

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
        _locationManager.distanceFilter = kCLDistanceFilterNone;
    }
	return _locationManager;
}

- (NSMutableArray *) savedLocationsArray
{
    if (!_savedLocationsArray)
        _savedLocationsArray = [[NSMutableArray alloc]init];
    return _savedLocationsArray;
}

// This function is called whenever LocationTracker receives a
// notification that the application has gone into the background
- (void) applicationDidEnterBackground: (NSNotification *) notification
{
    if(IS_OS_8_OR_LATER)
        [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
    
    //Use the BackgroundTaskManager to manage all the background Task
    self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];
}

- (void) restartLocationUpdates
{
    NSLog(@"restartLocationUpdates");
    
    if (self.beginUpdateLocationEveryNSecondsTimer)
    {
        [self.beginUpdateLocationEveryNSecondsTimer invalidate];
        self.beginUpdateLocationEveryNSecondsTimer = nil;
    }
    
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
    
    if (self.beginUpdateLocationEveryNSecondsTimer)
    {
        [self.beginUpdateLocationEveryNSecondsTimer invalidate];
        self.beginUpdateLocationEveryNSecondsTimer = nil;
    }
    
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
        
        /*
        NSTimeInterval locationAge = -[location.timestamp timeIntervalSinceNow];
        if (locationAge > 30.0)
            continue;
        */
        
        //Select only valid location with good accuracy
        if(location &&
           locationAccurary >= 0 &&
           locationAccurary <= ACCURACY_TOLERANCE &&
           (!(locationCoordinate.latitude == 0.0 && locationCoordinate.longitude == 0.0)))
        {
            self.lastLocationCoordinate = locationCoordinate;
            self.lastLocationAccuracy= locationAccurary;
            
            NSDictionary *locationDictionary = @{ COORDINATE : @{ LATITUDE : [NSNumber numberWithDouble:locationCoordinate.latitude],
                                                                  LONGITUDE : [NSNumber numberWithDouble:locationCoordinate.longitude]},
                                                  ACCURACY : [NSNumber numberWithDouble:locationAccurary]};
            
            //Add the vallid location with good accuracy into an array
            //Every 1 minute, I will select the best location based on accuracy and send to server
            [self.savedLocationsArray addObject:locationDictionary];
        }
        else
            NSLog(@"Location is either not valid or it is not accurate enough");

    }
    
    // If the timer still valid, return it (Will not run the code below)
    if (self.beginUpdateLocationEveryNSecondsTimer)
        return;
    
    self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];
    
    // Restart the locationManager after
    self.beginUpdateLocationEveryNSecondsTimer = [NSTimer scheduledTimerWithTimeInterval:BEGIN_UPDATE_LOCATION_EVERY_N_SECONDS
                                                                                              target:self
                                                                                            selector:@selector(restartLocationUpdates)
                                                                                            userInfo:nil
                                                                                             repeats:NO];
    
    //Will only stop the locationManager after N seconds, so that we can get some accurate locations
    //The location manager will only operate for N seconds to save battery
    if (self.updateLocationForNSecondsTimer)
    {
        [self.updateLocationForNSecondsTimer invalidate];
        self.updateLocationForNSecondsTimer = nil;
    }
    
    self.updateLocationForNSecondsTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_LOCATION_FOR_N_SECONDS
                                                                           target:self
                                                                         selector:@selector(stopLocationUpdates)
                                                                         userInfo:nil
                                                                          repeats:NO];

}

//Stop the locationManager
- (void) stopLocationUpdates
{
    NSLog(@"locationManager stopLocationUpdates");
    [self.locationManager stopUpdatingLocation];
}


- (void) locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
   // NSLog(@"locationManager error:%@",error);
    
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


// Send the location to Server
- (void) saveLocation
{
    
    NSLog(@"savingLocation");
    
    // Find the most accurate location from the array based on accuracy
    NSMutableDictionary *mostAccurateLocation = [[NSMutableDictionary alloc]init];
    
    for(int i=0; i<self.savedLocationsArray.count; i++)
    {
        NSMutableDictionary *currentLocation = self.savedLocationsArray[i];
        if (i==0) // First is the best initially
            mostAccurateLocation = currentLocation;
        else if ( [currentLocation[ACCURACY] floatValue] <= [mostAccurateLocation[ACCURACY] floatValue])
            mostAccurateLocation = currentLocation;
    }
    
    // If the array's size is 0, get the last know location; sometimes due to network issues or unknown reasons, you cannot
    // get the location during the previous period, so the best you can do is send the last known location to the server
    if(self.savedLocationsArray.count == 0)
    {
        NSLog(@"Unable to get location. Using the last known location.");
        self.currentLocation = self.lastLocationCoordinate;
        self.currentLocationAccuracy = self.lastLocationAccuracy;
    }
    else
    {
        self.currentLocation = CLLocationCoordinate2DMake([mostAccurateLocation[COORDINATE][LATITUDE] doubleValue],
                                                          [mostAccurateLocation[COORDINATE][LATITUDE] doubleValue]);
        self.currentLocationAccuracy = [mostAccurateLocation[ACCURACY] doubleValue];
    }
    
    NSLog(@"Saving to CoreData: Latitude(%f) Longitude(%f) Accuracy(%f)",
          self.currentLocation.latitude,
          self.currentLocation.longitude,
          self.currentLocationAccuracy);
    
    //TODO: Your code to send the self.myLocation and self.myLocationAccuracy to your server
    
    //After sending the location to the server successful, remember to clear the current array with the following code. It is to make sure that you clear up old location in the array and add the new locations from locationManager
    [self.savedLocationsArray removeAllObjects];
    self.savedLocationsArray = nil;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // TO DO
}


@end
