//
//  POGAppDelegate.h
//  PathOGion
//
//  Created by Simon Ayzman on 2/7/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class POGLocationTracker;
@class POGCoreDataManager;

@interface POGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) POGLocationTracker *locationTracker;
@property (strong, nonatomic) POGCoreDataManager *coreDataManager;

@end

