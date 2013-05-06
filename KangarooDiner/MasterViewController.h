//
//  MasterViewController.h
//  Kangaroo Menu
//
//  Created by Dev Mohanty on 10/24/12.
//  Copyright (c) 2012 Dev Mohanty. All rights reserved.
//
/*
 This defines the properties of the Master View Controller(Main)
 */
#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) DetailViewController *detailViewController;


@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

//data is stored here
@property (nonatomic,retain) NSDictionary *tableContents;//meal items
@property (nonatomic,retain) NSArray *sortedKeys;//breakfast/lunch/dinner

//todays date/time
@property (nonatomic,retain) NSDate *todayMain;
@property (nonatomic,retain) NSDate *mealChosen;
- (IBAction)valueChanged:(id)sender;


@end
