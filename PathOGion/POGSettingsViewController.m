//
//  POGSettingsViewController.m
//  PathOGion
//
//  Created by Simon Ayzman on 3/24/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import "POGSettingsViewController.h"
#import "POGSelectUserLocationPathViewController.h"
#import "POGDeleteUserLocationPathViewController.h"
#import "POGInfectedPatientLocationPathTableViewController.h"

@interface POGSettingsViewController ()

@end

@implementation POGSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setup
{

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"selectUserLocationPathSetting"])
    {
        POGSelectUserLocationPathViewController *svc = [segue destinationViewController];
    }
    else if ([[segue identifier] isEqualToString:@"deleteUserLocationPathSetting"])
    {
        POGDeleteUserLocationPathViewController *dvc = [segue destinationViewController];

    }
    else if ([[segue identifier] isEqualToString:@"showInfectedPatientPaths"])
    {
        POGInfectedPatientLocationPathTableViewController *ptvc = [segue destinationViewController];
    }
    else
    {
        NSLog(@"Identifier: %@. Fatal error.", [segue identifier]);
    }
    
}


@end
