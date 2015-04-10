//
//  POGAppDelegate.m
//  PathOGion
//
//  Created by Simon Ayzman on 2/7/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import "POGAppDelegate.h"
#import "POGCoreDataLocationPoint.h"
#import "POGLocationPoint.h"

@interface POGAppDelegate ()

@end

@implementation POGAppDelegate

#pragma mark - UIApplication Delegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self coreDataSweepThrough];
    [self initializeLocationServices];
    [self initializeLocalNotificationScheduler];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"application openURL sourceApplication annotation");

    /*
     
     Code to retrive file paths
     
     NSFileManager *filemgr = [NSFileManager defaultManager];
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsDirectory = [paths objectAtIndex:0];
     NSString* inboxPath = [documentsDirectory stringByAppendingPathComponent:@"Inbox"];
     NSArray *dirFiles = [filemgr contentsOfDirectoryAtPath:inboxPath error:nil];
 
    */
    
    return false;
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

- (void) application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    
}

#pragma mark - Relevant Methods

- (void) initializeLocationServices
{
    NSLog(@"initializeLocationServices");
    
    UIAlertView * alert;
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"This app does not work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disabled."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else
    {
        self.locationTracker = [POGLocationTracker sharedLocationTracker];
        [self.locationTracker startLocationTracking];
    }
}

- (void) initializeLocalNotificationScheduler
{
    NSLog(@"initializeLocalNotificationScheduler");
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *nextMidnight = [calendar nextDateAfterDate:[NSDate date]
                                          matchingHour:0
                                                minute:0
                                                second:0
                                               options:NSCalendarMatchNextTime];
    if(localNotifications.count > 0)
    {
        NSLog(@"Local notifications currently scheduled:");
        int counter = 1;
        for (UILocalNotification *localNotification in localNotifications)
        {
            NSLog(@"Notification %d fire date: %@", counter, localNotification.fireDate);
            NSComparisonResult result = [calendar compareDate:localNotification.fireDate toDate:nextMidnight toUnitGranularity:NSCalendarUnitSecond];
            if (result != NSOrderedSame)
            {
                NSLog(@"Deleting incorrect recurring location notification.");
                [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            }
            else
            {
                NSLog(@"Recurring local notification already exists.");
            }
            counter++;
        }
    }
    if (localNotifications.count == 0)
    {
        NSLog(@"Registering recurring local notification.");
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = nextMidnight;
        notification.timeZone = [NSTimeZone localTimeZone];
        notification.alertBody = @"Don't forget to turn on PathOGion to keep track of your location!";
        notification.alertAction = @"go to application";
        notification.repeatInterval= NSCalendarUnitDay;
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

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

- (NSArray *)savedCoreDataLocationPoints
{
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
}

- (void) displayAllCoreDataLocationPoints
{
    NSArray *coreDataLocationPoints = [self savedCoreDataLocationPoints];
    for (POGCoreDataLocationPoint *coreDataLocationPoint in coreDataLocationPoints)
        NSLog(@"[%@]: (%f, %f) within %.2f meters.", coreDataLocationPoint.timestamp, coreDataLocationPoint.latitude, coreDataLocationPoint.longitude, coreDataLocationPoint.accuracy);
}

- (void) deleteAllCoreDataLocationPoints
{
    NSLog(@"deleteAllCoreDataLocationPoints");
    NSArray *coreDataLocationPoints = [self savedCoreDataLocationPoints];
    for (POGCoreDataLocationPoint *coreDataLocationPoint in coreDataLocationPoints)
        [self.managedObjectContext deleteObject:coreDataLocationPoint];
    [self saveContext];
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
    NSLog(@"deleteCoreDataLocationPoint");
    [self.managedObjectContext deleteObject:coreDataLocationPoint];
    [self saveContext];
}

@end
