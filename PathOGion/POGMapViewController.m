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
}

- (void) setPatientLocationPath: (POGLocationPath *) locationPath
{
    _patientLocationPath = locationPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self navigationBarSetup];
    [self mapViewSetup];
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
    POGAppDelegate *app = (POGAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext = app.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"POGCoreDataLocationPoint"];
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
        POGLocationPath *locationPath = [[POGLocationPath alloc] initWithLocationPoints:
                                         [POGLocationPoint locationPointsFromCoreDataLocationPoints:coreDataLocationPoints]];
        self.userLocationPath = locationPath;
        
        POGLocationPoint *lastKnownLocation = [locationPath mostRecentLocationPoint];
        [self.mapView setRegion:MKCoordinateRegionMake([lastKnownLocation CLLocationCoordinate2D], MKCoordinateSpanMake(0.1f, 0.1f))
                       animated:YES];

    }
}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Application Properties

//-(BOOL)prefersStatusBarHidden
//{
//    return YES;
//}


@end
