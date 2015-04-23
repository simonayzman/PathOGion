//
//  POGSelectUserLocationPathViewController.m
//  PathOGion
//
//  Created by Simon Ayzman on 4/7/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import "POGSelectUserLocationPathViewController.h"

@interface POGSelectUserLocationPathViewController ()

@property (strong, nonatomic) IBOutlet UIDatePicker *lowerValueDatePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *upperValueDatePicker;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *dateExistsLabel;

@end

@implementation POGSelectUserLocationPathViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setup
{
    [self setDatesOfDatePickers];
    [self updateDateExistsLabelForDatesSelected];
}

- (void) setDatesOfDatePickers
{
    //[self setDateOfLowerValueDatePicker:self.lowerTimeBound];
    //[self setDateOfUpperValueDatePicker:self.upperTimeBound];
    [self setDatesOfLowerDatePicker:self.lowerTimeBound upperDatePicker:self.upperTimeBound];
}

- (void) updateDateExistsLabelForDatesSelected
{
    
}

- (void) setDatesOfLowerDatePicker: (NSDate *) lowerTimeBound
                  upperDatePicker: (NSDate *) upperTimeBound
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.lowerValueDatePicker.date = lowerTimeBound;
    NSDate *minimumUpperValueDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:self.lowerValueDatePicker.date options:0];
    self.upperValueDatePicker.minimumDate = minimumUpperValueDate;
    self.upperValueDatePicker.date = upperTimeBound;
    NSDate *maximumLowerValueDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:-1 toDate:self.upperValueDatePicker.date options:0];
    self.lowerValueDatePicker.maximumDate = maximumLowerValueDate;
}

/*
- (void) setDateOfLowerValueDatePicker: (NSDate *) lowerTimeBound
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // Update the date of the lowerValueDatePicker
    NSDate *maximumLowerValueDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:-1 toDate:self.upperValueDatePicker.date options:0];
    if (lowerTimeBound > maximumLowerValueDate)
        self.lowerValueDatePicker.date = maximumLowerValueDate;
    else
        self.lowerValueDatePicker.date = lowerTimeBound;
    
    // Update the minimum of the upperValueDatePicker
    NSDate *minimumUpperValueDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:self.lowerValueDatePicker.date options:0];
    self.upperValueDatePicker.minimumDate = minimumUpperValueDate;
}

- (void) setDateOfUpperValueDatePicker: (NSDate *) upperTimeBound
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // Update the date of the upperValueDatePicker
    NSDate *minimumUpperValueDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:self.lowerValueDatePicker.date options:0];
    if (upperTimeBound < minimumUpperValueDate)
        self.upperValueDatePicker.date = minimumUpperValueDate;
    else
        self.upperValueDatePicker.date = upperTimeBound;
    
    // Update the maximum of the lowerValueDatePicker
    NSDate *maximumLowerValueDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:-1 toDate:self.upperValueDatePicker.date options:0];
    self.lowerValueDatePicker.maximumDate = maximumLowerValueDate;
}
*/

// AFTER THE BELOW WORKS CONSIDER REFACTORING SO THAT THE SETTING
// OF THE DATES CAN SIMPLY OCCUR INSIDE SOME SORT OF WRAPPER FUNCTION

- (IBAction)lowerValueDatePickerValueChanged:(UIDatePicker *)sender forEvent:(UIEvent *)event
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *minimumUpperValueDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:self.lowerValueDatePicker.date options:0];
    self.upperValueDatePicker.minimumDate = minimumUpperValueDate;
    
    if ([self.delegate respondsToSelector:@selector(lowerValueDateUpdated:)])
    {
        [self.delegate lowerValueDateUpdated:sender.date];
    }
}

- (IBAction)upperValueDatePickerValueChanged:(UIDatePicker *)sender forEvent:(UIEvent *)event
{
    self.upperValueDatePicker.maximumDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *maximumLowerValueDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:-1 toDate:self.upperValueDatePicker.date options:0];
    self.lowerValueDatePicker.maximumDate = maximumLowerValueDate;
    
    if ([self.delegate respondsToSelector:@selector(upperValueDateUpdated:)])
    {
        [self.delegate upperValueDateUpdated:sender.date];
    }
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
