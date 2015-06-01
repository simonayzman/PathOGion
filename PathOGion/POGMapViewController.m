//
//  POGMapViewController.m
//  PathOGion
//
//  Created by Simon Ayzman on 3/24/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POGMapViewController.h"
#import "POGLocationPath.h"
#import "POGCoreDataManager.h"
#import "POGLocationPoint.h"
#import "POGLocationTracker.h"
#import "CLLocation+measuring.h"

@interface POGMapViewController ()

@property (weak, nonatomic) POGCoreDataManager *coreDataManager;
@property (weak, nonatomic) POGLocationTracker *locationTracker;
@property (assign, nonatomic) BOOL boundsChanged;
@property (strong, nonatomic) NSMutableArray *userLocationAnnotations;
@property (strong, nonatomic) NSMutableArray *userLocationOverlays;
@property (strong, nonatomic) NSMutableArray *patientLocationAnnotations;
@property (strong, nonatomic) NSMutableArray *patientLocationOverlays;

@end

@implementation POGMapViewController

#pragma mark - Custom setters

- (void) setUserLocationPath: (POGLocationPath *) locationPath
{
    _userLocationPath = locationPath;
    [self redisplayUserLocationPath];
}

- (void) setPatientLocationPath: (POGLocationPath *) locationPath
{
    _patientLocationPath = locationPath;
    [self redisplayPatientLocationPath];
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.boundsChanged)
    {
        NSArray *coreDataLocationPoints = [self.coreDataManager savedCoreDataLocationPointsFromDate:self.lowerTimeBound toDate:self.upperTimeBound];
        POGLocationPath *locationPath = [[POGLocationPath alloc] initWithLocationPoints:
                                         [POGLocationPoint locationPointsFromCoreDataLocationPoints:coreDataLocationPoints]];
        self.userLocationPath = locationPath;
        self.boundsChanged = NO;
    }
}

#pragma mark - Setup functions

- (void) setup
{
    [self dataSetup];
    [self timeBoundsSetup];
    [self navigationBarSetup];
    [self mapViewSetup];
}

- (void) dataSetup
{
    _boundsChanged = YES;
    _coreDataManager = [POGCoreDataManager sharedCoreDataManager];
    _locationTracker = [POGLocationTracker sharedLocationTracker];
    _userLocationAnnotations = [NSMutableArray array];
    _userLocationOverlays = [NSMutableArray array];
    _patientLocationAnnotations = [NSMutableArray array];
    _patientLocationOverlays = [NSMutableArray array];
}

- (void) timeBoundsSetup
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now = [NSDate date];
    NSDate *yesterday = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:now options:0];
    _lowerTimeBound = yesterday;
    _upperTimeBound = now;
}

- (void) navigationBarSetup
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void) mapViewSetup
{
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = true;
    self.mapView.zoomEnabled = true;
    self.mapView.scrollEnabled = true;
    [self.mapView setRegion:MKCoordinateRegionMake([self.locationTracker.currentLocation CLLocationCoordinate2D], MKCoordinateSpanMake(0.02f, 0.05f))
                   animated:YES];
}

#pragma mark - View Targets

- (IBAction)refresh:(UIBarButtonItem *)sender
{
    [self refreshMapView];
}

#pragma mark - User location path functions

- (void) refreshMapView
{
    self.upperTimeBound = [NSDate date];
    NSArray *coreDataLocationPoints = [self.coreDataManager savedCoreDataLocationPointsFromDate:self.lowerTimeBound toDate:self.upperTimeBound];
    POGLocationPath *locationPath = [[POGLocationPath alloc] initWithLocationPoints:
                                     [POGLocationPoint locationPointsFromCoreDataLocationPoints:coreDataLocationPoints]];
    self.userLocationPath = locationPath;
    [self.mapView setRegion:MKCoordinateRegionMake([self.locationTracker.currentLocation CLLocationCoordinate2D], MKCoordinateSpanMake(0.02f, 0.05f))
                   animated:YES];
}

- (void) redisplayUserLocationPath
{
    if (self.userLocationPath)
    {

        [self resetUserLocationsOnMapView];
        NSMutableArray *overlays = [NSMutableArray array];
        NSMutableArray *annotations = [NSMutableArray array];
        
        NSDateFormatter *timeFormatter = [self preferredTimeFormatter];
        NSDateFormatter *dateFormatter = [self preferredDateFormatter];
        
        NSArray *locationPointArray = [self.userLocationPath getLocationPath];
        
        CLLocationCoordinate2D *locationPointCoordinates = malloc(sizeof(CLLocationCoordinate2D) * [locationPointArray count]);
        NSUInteger locationPointCoordinatesCounter = 0;

        CLLocationCoordinate2D *beginningIndexOfCurrentPolylineInLocationPointCoordinates = locationPointCoordinates;
        NSUInteger numberOfCoordinatesOnCurrentPolyline = 0;
        POGLocationPoint *previousLocationPoint;
        
        for (POGLocationPoint *locationPoint in locationPointArray)
        {
            if (locationPoint.accuracy <= ACCURACY_TOLERANCE)
            {
                // Addition of circle overlay to temporary overlay container
                MKCircle *circle = [MKCircle circleWithCenterCoordinate:[locationPoint CLLocationCoordinate2D] radius:locationPoint.accuracy];
                [overlays addObject:circle];

                // Addition of point annotation to temporary annotation container
                MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
                pin.coordinate = [locationPoint CLLocationCoordinate2D];
                pin.title = [NSString stringWithFormat:@"%@ (%@)",
                             [timeFormatter stringFromDate:locationPoint.timestamp],
                             [dateFormatter stringFromDate:locationPoint.timestamp]];
                pin.subtitle  = [NSString stringWithFormat:@"Within %.0f meters", locationPoint.accuracy];
                [annotations addObject:pin];
                
                // Polyline calculation
                locationPointCoordinatesCounter++;
                locationPointCoordinates[locationPointCoordinatesCounter-1] = [locationPoint CLLocationCoordinate2D];
                if (previousLocationPoint && [CLLocation distanceFromCoordinate:[locationPoint CLLocationCoordinate2D] toCoordinate:[previousLocationPoint CLLocationCoordinate2D]] > locationPoint.accuracy + previousLocationPoint.accuracy + 2 * DISTANCE_FILTER)
                {
                    // Finish off the first polyline
                    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:beginningIndexOfCurrentPolylineInLocationPointCoordinates
                                                                         count:numberOfCoordinatesOnCurrentPolyline];
                    [overlays addObject:polyline];
                    beginningIndexOfCurrentPolylineInLocationPointCoordinates = &(locationPointCoordinates[locationPointCoordinatesCounter-1]);

                    // Create the second polyline: TO DO
                    numberOfCoordinatesOnCurrentPolyline = 0;
                }
                numberOfCoordinatesOnCurrentPolyline++;
                previousLocationPoint = locationPoint;
            }
        }

        // Addition of polyline to temporary overlay container
        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:beginningIndexOfCurrentPolylineInLocationPointCoordinates count:numberOfCoordinatesOnCurrentPolyline];
        [overlays addObject:polyline];
        
        // Actual addition of overlays/annotations to mapView
        [self.mapView addOverlays:[overlays copy]];
        [self.userLocationOverlays addObjectsFromArray:[overlays copy]];
        [self.mapView addAnnotations:[annotations copy]];
        [self.userLocationAnnotations addObjectsFromArray:[annotations copy]];

        // Final memory cleanup
        realloc(locationPointCoordinates,0);
        locationPointCoordinates = nil;
    }
}

- (void) resetUserLocationsOnMapView
{
    [self.mapView removeOverlays:[self.userLocationOverlays copy]];
    [self.mapView removeAnnotations:[self.userLocationAnnotations copy]];
}

#pragma mark - Patient location path functions

- (void) redisplayPatientLocationPath
{
    if (self.patientLocationPath)
    {
        [self resetPatientLocationsOnMapView];
        NSMutableArray *overlays = [NSMutableArray array];
        NSMutableArray *annotations = [NSMutableArray array];
        
        NSDateFormatter *timeFormatter = [self preferredTimeFormatter];
        NSDateFormatter *dateFormatter = [self preferredDateFormatter];
        
        NSArray *locationPointArray = [self.patientLocationPath getLocationPath];
        
        CLLocationCoordinate2D *locationPointCoordinates = malloc(sizeof(CLLocationCoordinate2D) * [locationPointArray count]);
        NSUInteger locationPointCoordinatesCounter = 0;
        
        CLLocationCoordinate2D *beginningIndexOfCurrentPolylineInLocationPointCoordinates = locationPointCoordinates;
        NSUInteger numberOfCoordinatesOnCurrentPolyline = 0;
        POGLocationPoint *previousLocationPoint;
        
        for (POGLocationPoint *locationPoint in locationPointArray)
        {
            locationPoint.accuracy = 10.0;
            if (locationPoint.accuracy <= ACCURACY_TOLERANCE)
            {
                // Addition of circle overlay to temporary overlay container
                MKCircle *circle = [MKCircle circleWithCenterCoordinate:[locationPoint CLLocationCoordinate2D] radius:locationPoint.accuracy];
                [overlays addObject:circle];
                
                // Addition of point annotation to temporary annotation container
                MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
                pin.coordinate = [locationPoint CLLocationCoordinate2D];
                pin.title = [NSString stringWithFormat:@"%@ (%@)*",
                             [timeFormatter stringFromDate:locationPoint.timestamp],
                             [dateFormatter stringFromDate:locationPoint.timestamp]];
                pin.subtitle  = [NSString stringWithFormat:@"Within %.0f meters", locationPoint.accuracy];
                [annotations addObject:pin];
                [self.mapView addAnnotation:pin];
                
                
                // Polyline calculation
                
                locationPointCoordinates[locationPointCoordinatesCounter++] = [locationPoint CLLocationCoordinate2D];

                /*
                locationPointCoordinatesCounter++;
                locationPointCoordinates[locationPointCoordinatesCounter-1] = [locationPoint CLLocationCoordinate2D];
                if (previousLocationPoint && [CLLocation distanceFromCoordinate:[locationPoint CLLocationCoordinate2D] toCoordinate:[previousLocationPoint CLLocationCoordinate2D]] > locationPoint.accuracy + previousLocationPoint.accuracy + 2 * DISTANCE_FILTER)
                {
                    // Finish off the first polyline
                    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:beginningIndexOfCurrentPolylineInLocationPointCoordinates
                                                                         count:numberOfCoordinatesOnCurrentPolyline];
                    [overlays addObject:polyline];
                    beginningIndexOfCurrentPolylineInLocationPointCoordinates = &(locationPointCoordinates[locationPointCoordinatesCounter-1]);
                    
                    // Create the second polyline: TO DO
                    numberOfCoordinatesOnCurrentPolyline = 0;
                }
                numberOfCoordinatesOnCurrentPolyline++;
                previousLocationPoint = locationPoint;
                 */
            }
        }
        
        // Addition of polyline to temporary overlay container
        //MKPolyline *polyline = [MKPolyline polylineWithCoordinates:beginningIndexOfCurrentPolylineInLocationPointCoordinates count:numberOfCoordinatesOnCurrentPolyline];
        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:locationPointCoordinates count:locationPointCoordinatesCounter];
        [overlays addObject:polyline];
        
        // Actual addition of overlays/annotations to mapView
        [self.mapView addOverlays:[overlays copy]];
        [self.patientLocationOverlays addObjectsFromArray:[overlays copy]];
        [self.mapView addAnnotations:[annotations copy]];
        [self.patientLocationAnnotations addObjectsFromArray:[annotations copy]];
        
        // Final memory cleanup
        realloc(locationPointCoordinates,0);
        locationPointCoordinates = nil;
    }
}

- (void) resetPatientLocationsOnMapView
{
    [self.mapView removeOverlays:[self.patientLocationOverlays copy]];
    [self.mapView removeAnnotations:[self.patientLocationAnnotations copy]];
}


#pragma mark - MapView Delegate

/*
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {}
-(void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers {}
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {}
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {}
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {}
*/

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = nil;
    NSString *title = [annotation title];
    NSString *lastCharacter = [title substringWithRange:NSMakeRange([title length]-1, 1)];
    if ([annotation isKindOfClass:[MKCircle class]])
    {
        annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"circle"];
        if (!annotationView)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"circle"];
            annotationView.canShowCallout = YES;
        }
    }
    else if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        if ([lastCharacter isEqualToString: @"*"])
        {
            annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"patientpin"];
            if (!annotationView)
            {
                MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"patientpin"];
                pinView.pinColor = MKPinAnnotationColorRed;
                pinView.animatesDrop = YES;
                annotationView = pinView;
            }
        }
        else
        {
            annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"userpin"];
            if (!annotationView)
            {
                MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"userpin"];
                pinView.pinColor = MKPinAnnotationColorGreen;
                pinView.animatesDrop = YES;
                annotationView = pinView;
            }
        }
        annotationView.canShowCallout = YES;
    }
    return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.strokeColor = [UIColor blackColor];
        polylineRenderer.lineWidth = 1.5f;
        return polylineRenderer;
    }
    else if ([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        if (((MKCircle *)overlay).radius == 0)
        {
            circleRenderer.fillColor = [UIColor colorWithRed:0.4f green:0.0f blue:0.f alpha:0.15f];
            circleRenderer.strokeColor = [UIColor colorWithRed:0.8f green:0.0f blue:0.f alpha:0.3f];
        }
        else if (((MKCircle *)overlay).radius > ACCURACY_TOLERANCE)
        {
            circleRenderer.fillColor = [UIColor colorWithRed:0.f green:1.f blue:0.f alpha:0.05f];
            circleRenderer.strokeColor = [UIColor colorWithRed:0.f green:1.f blue:0.f alpha:0.3f];
        }
        else
        {
            circleRenderer.fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.4f alpha:0.15f];
            circleRenderer.strokeColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.8f alpha:0.3f];
        }
        circleRenderer.lineWidth = 3.0f;
        return circleRenderer;
    }
    NSLog(@"Overlay type not recognized in rendererForOverlay delegate method: %@", overlay);
    return [[MKOverlayRenderer alloc] initWithOverlay:overlay];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Select User Path Date Protocol

- (void)lowerValueDateUpdated:(NSDate *)updatedLowerDate
{
    self.lowerTimeBound = updatedLowerDate;
    self.boundsChanged = YES;
}

- (void)upperValueDateUpdated:(NSDate *)updatedUpperDate
{
    self.upperTimeBound = updatedUpperDate;
    self.boundsChanged = YES;
}

#pragma mark - Select Infected Patient Location Path Protocol

- (void) infectedPatientLocationPathUpdated:(POGLocationPath *) infectedPatientLocationPath
{
    self.patientLocationPath = infectedPatientLocationPath;
}

#pragma mark - Misc.

- (NSDateFormatter *) preferredDateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setDateFormat:@"M'/'d'/'yy"];
    return dateFormatter;
}

- (NSDateFormatter *) preferredTimeFormatter
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [timeFormatter setDateFormat:@"h:mm a"];
    return timeFormatter;
}



@end
