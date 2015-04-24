//
//  POGCoreDataManager.m
//  PathOGion
//
//  Created by Simon Ayzman on 4/23/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLLocation+measuring.h"
#import "POGCoreDataManager.h"
#import "POGCoreDataLocationPoint.h"
#import "POGLocationPoint.h"
#import "POGLocationTracker.h"

@implementation POGCoreDataManager

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype) sharedCoreDataManager
{
    static id _sharedCoreDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCoreDataManager = [[self alloc] initPrivate];
    });
    return _sharedCoreDataManager;
}

- (instancetype) initPrivate
{
    if (self = [super init])
    {
        // Not much to initialize here
    }
    return self;
}

- (instancetype) init
{
    NSLog(@"Cannot use init with singleton class POGCoreDateManager.");
    abort();
    return nil;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.carsilab.PathOGion" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PathOGion" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    //[self reset];
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PathOGion.sqlite"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Cleanup

- (void)reset
{
    // Release CoreData chain
    _managedObjectContext = nil;
    _managedObjectModel = nil;
    _persistentStoreCoordinator = nil;
    
    // Delete the sqlite file
    NSError *error = nil;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PathOGion.sqlite"];
    if ([fileManager fileExistsAtPath:storeURL.path])
        [fileManager removeItemAtURL:storeURL error:&error];
    if (error)
    {
        NSLog(@"Error handled in reset");
        abort();
    }
}

- (void) coreDataSweepThrough
{
    NSArray *coreDataLocationPoints = [self savedCoreDataLocationPoints];
    NSUInteger total = [coreDataLocationPoints count];
    NSUInteger deletions = 0;
    for (NSInteger i = total - 1; i > 0; )
    {
        POGCoreDataLocationPoint *coreDataLocationPoint = coreDataLocationPoints[i];
        POGCoreDataLocationPoint *nextCoreDataLocationPoint = coreDataLocationPoints[i-1];
        
        CLLocationCoordinate2D locationPointCoordinate = [[[POGLocationPoint alloc] initWithCoreDataLocationPoint: coreDataLocationPoint] CLLocationCoordinate2D];
        CLLocationCoordinate2D nextLocationPointCoordinate = [[[POGLocationPoint alloc] initWithCoreDataLocationPoint: nextCoreDataLocationPoint] CLLocationCoordinate2D];
        
        double distance = [CLLocation distanceFromCoordinate:locationPointCoordinate toCoordinate:nextLocationPointCoordinate];
        if (distance < DISTANCE_FILTER)
        {
            [self deleteCoreDataLocationPoint:nextCoreDataLocationPoint];
            deletions++;
        }
        else
            --i;
    }
    NSLog(@"Total records: %ld\nTotal deletions: %ld", total, deletions);
}


#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data Information Retrieval and Deletion support

- (POGCoreDataLocationPoint *) mostRecentSavedCoreDataLocationPoint
{
    NSError *error;
    NSString *timestamp = @"timestamp";
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"POGCoreDataLocationPoint"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:timestamp ascending:NO]];
    request.fetchBatchSize = 1;
    NSArray *coreDataLocationPoints = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error)
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return coreDataLocationPoints[0];
}

- (NSArray *)savedCoreDataLocationPoints
{
    return [self savedCoreDataLocationPointsFromDate:[NSDate distantPast] toDate:[NSDate distantFuture]];
    /*
     NSError *error;
     NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"POGCoreDataLocationPoint"];
     request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
     [request setReturnsObjectsAsFaults:NO];
     NSArray *coreDataLocationPoints = [self.managedObjectContext executeFetchRequest:request error:&error];
     if (error)
     {
     // Replace this implementation with code to handle the error appropriately.
     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     abort();
     }
     return coreDataLocationPoints;
     */
}

- (NSArray *) savedCoreDataLocationPointsFromDate:(NSDate *) date
{
    return [self savedCoreDataLocationPointsFromDate:date toDate:[NSDate distantFuture]];
}

- (NSArray *) savedCoreDataLocationPointsToDate:(NSDate *) date
{
    return [self savedCoreDataLocationPointsFromDate:[NSDate distantPast] toDate:date];
}

- (NSArray *) savedCoreDataLocationPointsFromDate:(NSDate *)fromDate toDate:(NSDate *) toDate
{
    NSError *error;
    NSString *timestamp = @"timestamp";
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"POGCoreDataLocationPoint"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:timestamp ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@)", timestamp, fromDate, timestamp, toDate];
    [request setReturnsObjectsAsFaults:NO];
    NSArray *coreDataLocationPoints = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error)
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return coreDataLocationPoints;
}

- (void) deleteAllCoreDataLocationPoints
{
    [self deleteCoreDataLocationPointsFromDate:[NSDate distantPast] toDate:[NSDate distantFuture]];
}

- (void) deleteCoreDataLocationPointsFromDate:(NSDate *) date
{
    [self deleteCoreDataLocationPointsFromDate:date toDate:[NSDate distantFuture]];
}

- (void) deleteCoreDataLocationPointsToDate:(NSDate *) date
{
    [self deleteCoreDataLocationPointsFromDate:[NSDate distantPast] toDate:date];
}

- (void) deleteCoreDataLocationPointsFromDate:(NSDate *)fromDate toDate:(NSDate *) toDate
{
    NSArray *coreDataLocationPoints = [self savedCoreDataLocationPointsFromDate:fromDate toDate:toDate];
    for (POGCoreDataLocationPoint *coreDataLocationPoint in coreDataLocationPoints)
        [self.managedObjectContext deleteObject:coreDataLocationPoint];
    [self saveContext];
}

- (void) displayAllCoreDataLocationPoints
{
    NSArray *coreDataLocationPoints = [self savedCoreDataLocationPoints];
    for (POGCoreDataLocationPoint *coreDataLocationPoint in coreDataLocationPoints)
        NSLog(@"[%@]: (%f, %f) within %.2f meters.", coreDataLocationPoint.timestamp, coreDataLocationPoint.latitude, coreDataLocationPoint.longitude, coreDataLocationPoint.accuracy);
}

- (void) saveLocationPointToCoreData:(POGLocationPoint *)locationPoint
{
    POGCoreDataLocationPoint *coreDataLocationPoint = [NSEntityDescription insertNewObjectForEntityForName:@"POGCoreDataLocationPoint"
                                                                                    inManagedObjectContext:self.managedObjectContext];
    coreDataLocationPoint.latitude = locationPoint.latitude;
    coreDataLocationPoint.longitude = locationPoint.longitude;
    coreDataLocationPoint.accuracy = locationPoint.accuracy;
    coreDataLocationPoint.timestamp = locationPoint.timestamp;
    [self saveContext];
}

- (void)deleteCoreDataLocationPoint:(POGCoreDataLocationPoint *)coreDataLocationPoint
{
    //NSLog(@"deleteCoreDataLocationPoint");
    [self.managedObjectContext deleteObject:coreDataLocationPoint];
    [self saveContext];
}

@end
