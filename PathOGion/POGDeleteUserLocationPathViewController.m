//
//  POGDeleteUserLocationPathViewController.m
//  PathOGion
//
//  Created by Simon Ayzman on 4/7/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import "POGDeleteUserLocationPathViewController.h"

@interface POGDeleteUserLocationPathViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIDatePicker *lowerValueDatePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *upperValueDatePicker;
@end

@implementation POGDeleteUserLocationPathViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteLocations
{
    
}

- (IBAction)lowerValueDatePickerValueChanged:(UIDatePicker *)sender forEvent:(UIEvent *)event
{
    self.lowerValueDatePicker.maximumDate = self.upperValueDatePicker.date;
}
- (IBAction)upperValueDatePickerValueChanged:(UIDatePicker *)sender forEvent:(UIEvent *)event
{
    self.upperValueDatePicker.minimumDate = self.lowerValueDatePicker.date;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
