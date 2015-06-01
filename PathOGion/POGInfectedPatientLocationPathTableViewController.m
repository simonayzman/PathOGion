//
//  POGInfectedPatientLocationPathTableViewController.m
//  PathOGion
//
//  Created by Simon Ayzman on 4/7/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import "POGInfectedPatientLocationPathTableViewController.h"
#import "POGLocationPath.h"
#import "POGGeoJsonParser.h"

@interface POGInfectedPatientLocationPathTableViewController ()
@property (strong, nonatomic) NSArray *infectedPatientPathTitles;
@property (strong, nonatomic) NSArray *infectedPatientPaths;
@property (strong, nonatomic) NSIndexPath *previousSelection;
@end

@implementation POGInfectedPatientLocationPathTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setup
{
    [self setupInfectedPatientPaths];
}

- (void) setupInfectedPatientPaths
{
    NSMutableArray *infectedPatientPaths = [NSMutableArray array];
    NSMutableArray *infectedPatientPathTitles = [NSMutableArray array];

    POGGeoJsonParser *parser = [[POGGeoJsonParser alloc] init];
    
    POGLocationPath *locationPath1 = [parser getLocationPathFromGeoJsonFile:@"patient"];
    [infectedPatientPaths addObject:locationPath1];
    [infectedPatientPathTitles addObject:@"patient.geojson"];
    
    POGLocationPath *locationPath2 = [parser getLocationPathFromGeoJsonFile:@"patient_unsorted"];
    [infectedPatientPaths addObject:locationPath2];
    [infectedPatientPathTitles addObject:@"patient_unsorted.geojson"];

    _infectedPatientPaths = [infectedPatientPaths copy];
    _infectedPatientPathTitles = [infectedPatientPathTitles copy];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.previousSelection)
    {
        UITableViewCell *previousCell = [tableView cellForRowAtIndexPath:self.previousSelection];
        [previousCell setAccessoryType:UITableViewCellAccessoryNone];
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    self.previousSelection = indexPath;
 
    if ([self.delegate respondsToSelector:@selector(infectedPatientLocationPathUpdated:)])
    {
        POGLocationPath *path = (indexPath.row == 0) ? nil : self.infectedPatientPaths[indexPath.row-1];
        [self.delegate infectedPatientLocationPathUpdated:path];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.infectedPatientPaths count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infectedPatientPath" forIndexPath:indexPath];
    
    cell.textLabel.text = (indexPath.row == 0) ? @"None" : self.infectedPatientPathTitles[indexPath.row-1];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
