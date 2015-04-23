//
//  POGSelectUserLocationPathViewController.h
//  PathOGion
//
//  Created by Simon Ayzman on 4/7/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol POGSelectUserLocationPathDelegate <NSObject>

@optional
- (void) lowerValueDateUpdated:(NSDate *) updatedLowerDate;
- (void) upperValueDateUpdated:(NSDate *) updatedUpperDate;

@end

@interface POGSelectUserLocationPathViewController : UIViewController

@property (weak, nonatomic) id<POGSelectUserLocationPathDelegate> delegate;
@property (weak, nonatomic) NSDate *lowerTimeBound;
@property (weak, nonatomic) NSDate *upperTimeBound;

@end
