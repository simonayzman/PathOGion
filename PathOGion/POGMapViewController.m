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
#import "POGAppDelegate.h"
#import "POGLocationPoint.h"

@interface POGMapViewController ()

@end

@implementation POGMapViewController

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
    POGAppDelegate *app = (POGAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSArray *coreDataLocationPoints = [app savedCoreDataLocationPointsFromDate:self.lowerTimeBound toDate:self.upperTimeBound];
    POGLocationPath *locationPath = [[POGLocationPath alloc] initWithLocationPoints:
                                     [POGLocationPoint locationPointsFromCoreDataLocationPoints:coreDataLocationPoints]];
    self.userLocationPath = locationPath;
    
    POGLocationPoint *lastKnownLocation = [self.userLocationPath mostRecentLocationPoint];
    [self.mapView setRegion:MKCoordinateRegionMake([lastKnownLocation CLLocationCoordinate2D], MKCoordinateSpanMake(0.1f, 0.1f))
                   animated:YES];
    
}

/*
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}
*/

- (void) setup
{
    [self timeBoundsSetup];
    [self navigationBarSetup];
    [self mapViewSetup];
}

- (void) timeBoundsSetup
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now = [NSDate date];
    NSDate *yesterday = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:now options:0];
    self.lowerTimeBound = yesterday;
    self.upperTimeBound = now;
}

- (void) navigationBarSetup
{
    self.navigationController.navigationBar.translucent = YES;
    /*
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
     */
}

- (void) mapViewSetup
{
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = true;
    self.mapView.zoomEnabled = true;
    self.mapView.scrollEnabled = true;
}

- (void) redisplayUserLocationPath
{
    // TO DO
    // IMPLEMENT VERSION WHERE INACCURATE LOCATIONS
    // APPEAR DIFFERENTLY AS MKPOLYGONS OR MKCIRCLES
    // WITH MUCH SMALLER RADII (TO SHOW INACCURACY)
    
    NSMutableArray *overlays = [NSMutableArray array];
    NSMutableArray *annotations = [NSMutableArray array];
    
    NSArray *locationPointArray = [self.userLocationPath getLocationPath];
    CLLocationCoordinate2D *locationPointCoordinates = malloc(sizeof(CLLocationCoordinate2D) * [locationPointArray count]);
    NSUInteger counter = 0;
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [timeFormatter setDateFormat:@"h:mm a"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setDateFormat:@"M'/'d'/'yy"];

    for (POGLocationPoint *locationPoint in locationPointArray)
    {
        if (locationPoint.accuracy <= ACCURACY_TOLERANCE)
        {
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:[locationPoint CLLocationCoordinate2D] radius:locationPoint.accuracy];
            
            circle.title = [NSString stringWithFormat:@"%@ (%@)", [timeFormatter stringFromDate:locationPoint.timestamp], [dateFormatter stringFromDate:locationPoint.timestamp]];
            circle.subtitle  = [NSString stringWithFormat:@"Within %.0f meters", locationPoint.accuracy];
            //circle.title = [NSString stringWithFormat:@"Within %.0f meters", locationPoint.accuracy];
            //circle.subtitle  = [NSString stringWithFormat:@"%@ (%@)", [timeFormatter stringFromDate:locationPoint.timestamp], [dateFormatter stringFromDate:locationPoint.timestamp]];
            //circle.title = [timeFormatter stringFromDate:locationPoint.timestamp];
            //circle.subtitle  = [NSString stringWithFormat:@"%@ - %.0f m", [dateFormatter stringFromDate:locationPoint.timestamp], locationPoint.accuracy];
            
            [overlays addObject:circle];
            [annotations addObject:circle];
            locationPointCoordinates[counter] = [locationPoint CLLocationCoordinate2D];
            
            counter++;
        }
    }
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:locationPointCoordinates count:counter];

    [overlays addObject:polyline];
    
    [self.mapView addOverlays:[overlays copy]];
    [self.mapView addAnnotations:[annotations copy]];
    
    realloc(locationPointCoordinates,0);
    locationPointCoordinates = nil;
}

- (void) redisplayPatientLocationPath
{

}

#pragma mark - MapView Delegate

/*
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
}

- (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers
{

}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{

}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{

}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{

}
*/

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKCircle class]])
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"circle"];
        annotationView.canShowCallout = YES;
        return annotationView;
    }
    return nil;
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
        
        if (((MKCircle *)overlay).radius > ACCURACY_TOLERANCE)
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

#pragma mark - SelectViewController Protocol

- (void)lowerValueDateUpdated:(NSDate *)updatedLowerDate
{
    self.lowerTimeBound = updatedLowerDate;
}

- (void)upperValueDateUpdated:(NSDate *)updatedUpperDate
{
    self.upperTimeBound = updatedUpperDate;
}

#pragma mark - Application Properties

//-(BOOL)prefersStatusBarHidden
//{
//    return YES;
//}


@end
