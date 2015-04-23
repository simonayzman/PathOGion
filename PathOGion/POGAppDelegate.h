//
//  POGAppDelegate.h
//  PathOGion
//
//  Created by Simon Ayzman on 2/7/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "POGLocationTracker.h"

@class POGCoreDataLocationPoint;
@class POGLocationPoint;

@interface POGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) POGLocationTracker *locationTracker;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

- (NSArray *) savedCoreDataLocationPoints;
- (NSArray *) savedCoreDataLocationPointsFromDate:(NSDate *) date;
- (NSArray *) savedCoreDataLocationPointsToDate:(NSDate *) date;
- (NSArray *) savedCoreDataLocationPointsFromDate:(NSDate *)fromDate toDate:(NSDate *) toDate;

- (void) displayAllCoreDataLocationPoints;
- (void) deleteAllCoreDataLocationPoints;

- (void) saveLocationPointToCoreData:(POGLocationPoint *)locationPoint;
- (void) deleteCoreDataLocationPoint:(POGCoreDataLocationPoint *)coreDataLocationPoint;

@end

