//
//  POGMapViewController.h
//  PathOGion
//
//  Created by Simon Ayzman on 3/24/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "POGSelectUserLocationPathViewController.h"

@class POGLocationPath;

@interface POGMapViewController : UIViewController <MKMapViewDelegate, POGSelectUserLocationPathDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) POGLocationPath *userLocationPath;
@property (strong, nonatomic) POGLocationPath *patientLocationPath;

@property (strong, nonatomic) NSDate *lowerTimeBound;
@property (strong, nonatomic) NSDate *upperTimeBound;

@end
