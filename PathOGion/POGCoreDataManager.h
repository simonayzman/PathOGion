//
//  POGCoreDataManager.h
//  PathOGion
//
//  Created by Simon Ayzman on 4/23/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class POGCoreDataLocationPoint;
@class POGLocationPoint;

@interface POGCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype) sharedCoreDataManager;

- (void)saveContext;

- (POGCoreDataLocationPoint *) mostRecentSavedCoreDataLocationPoint;
- (NSArray *) savedCoreDataLocationPoints;
- (NSArray *) savedCoreDataLocationPointsFromDate:(NSDate *) date;
- (NSArray *) savedCoreDataLocationPointsToDate:(NSDate *) date;
- (NSArray *) savedCoreDataLocationPointsFromDate:(NSDate *)fromDate toDate:(NSDate *) toDate;

- (void) deleteAllCoreDataLocationPoints;
- (void) deleteCoreDataLocationPointsFromDate:(NSDate *) date;
- (void) deleteCoreDataLocationPointsToDate:(NSDate *) date;
- (void) deleteCoreDataLocationPointsFromDate:(NSDate *)fromDate toDate:(NSDate *) toDate;

- (void) displayAllCoreDataLocationPoints;

- (void) saveLocationPointToCoreData:(POGLocationPoint *)locationPoint;
- (void) deleteCoreDataLocationPoint:(POGCoreDataLocationPoint *)coreDataLocationPoint;


@end
