//
//  POGInfectedPatientLocationPathTableViewController.h
//  PathOGion
//
//  Created by Simon Ayzman on 4/7/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class POGLocationPath;

@protocol POGSelectInfectedPatientLocationPathDelegate <NSObject>

@optional
- (void) infectedPatientLocationPathUpdated:(POGLocationPath *) infectedPatientLocationPath;

@end


@interface POGInfectedPatientLocationPathTableViewController : UITableViewController

@property (weak, nonatomic) id<POGSelectInfectedPatientLocationPathDelegate> delegate;

@end
