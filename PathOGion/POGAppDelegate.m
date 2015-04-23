//
//  POGAppDelegate.m
//  PathOGion
//
//  Created by Simon Ayzman on 2/7/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import "POGAppDelegate.h"
#import "POGLocationTracker.h"
#import "POGCoreDataManager.h"

@interface POGAppDelegate ()

@end

@implementation POGAppDelegate

#pragma mark - UIApplication Delegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[self coreDataSweepThrough];
    [self initializeCoreData];
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
    [self.coreDataManager saveContext];
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
    [self.coreDataManager saveContext];
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

- (void) initializeCoreData
{
    NSLog(@"initializeCoreData");
    self.coreDataManager = [POGCoreDataManager sharedCoreDataManager];

}

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

@end
