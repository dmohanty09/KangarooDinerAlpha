//
//  MasterViewController.h
//  Kangaroo Menu
//
//  Created by Dev Mohanty on 10/24/12.
//  Copyright (c) 2012 Dev Mohanty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewController.h"
/*
 This defines the controller for the View displaying menu information for a given date
 */
@class DateViewController;

@interface DateViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (nonatomic,retain) NSDictionary *tableContents;//Meal Items
@property (nonatomic,retain) NSArray *sortedKeys;//Breakfast/lunch/dinner

@property (nonatomic,retain) NSDate *todayMain;//selected date
- (IBAction)valueChanged:(id)sender;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellSelected;


@end
