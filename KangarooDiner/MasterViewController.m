//
//  MasterViewController.m
//  Kangaroo Menu
//
//  Created by Dev Mohanty on 10/24/12.
//  Copyright (c) 2012 Dev Mohanty. All rights reserved.
//

#import "MasterViewController.h"

#import "DateViewController.h"

#import "Tutorial.h"

#import "DetailViewController.h"

#import "TFHpple.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
    
    NSDictionary *tableContents;// meal items
    NSArray *sortedKeys;// breakfast/lunch/dinner (Keys for Dictionary)
    
    NSDate *todayMain;
    
}
@end

/*
 This is the implementation of the Controller for the first view visited in the app
 */
@implementation MasterViewController
@synthesize tableContents;
@synthesize sortedKeys;
@synthesize todayMain;

/*
 initialize date/time
 */
- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
    
    todayMain = [[NSDate alloc] init];//todays date is set
    
    //NSLog(@"hello");
}

//set the dictionary when viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSLog([todayMain description]);
    
    [self setDictionary: todayMain];//calls method to fill dictionary with Menu Items
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
}

//setDictionary implementation
-(void)setDictionary:(NSDate*)today
{
    //Get breakfast/lunch/dinner time
    NSCalendar *gregorianTime = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components1 = [gregorianTime components: NSUIntegerMax fromDate: today];//components for breakfast (10am)
    [components1 setHour: 10];
    [components1 setMinute: 0];
    NSDateComponents *components2 = [gregorianTime components: NSUIntegerMax fromDate: today];//components for lunch (1pm)
    [components2 setHour: 13];
    [components2 setMinute: 0];
    NSDateComponents *components3 = [gregorianTime components: NSUIntegerMax fromDate: today];//components for dinner (8pm)
    [components3 setHour: 20];
    [components3 setMinute: 0];
    
    //get date objects for the specified components
    NSDate *breakfastTime = [gregorianTime dateFromComponents: components1];
    NSDate *lunchTime = [gregorianTime dateFromComponents: components2];
    NSDate *dinnerTime = [gregorianTime dateFromComponents: components3];
    
    //[gregorianTime release];
    
    //if its after dinner, show tomorrows menu
    if([today laterDate:dinnerTime]==today){
        NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:[NSDate date]];//one day after today
        //set the date equal to tomorrows date
        today = tomorrow;
    }
    
    //find sunday's date:
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:today];
    /*
     Create a date components to represent the number of days to subtract
     from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so
     subtract 1 from the number
     of days to subtract from the date in question.  (If today's Sunday,
     subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    /* Substract [gregorian firstWeekday] to handle first day of the week being something else than Sunday */
    [componentsToSubtract setDay: - ([weekdayComponents weekday] - [gregorian firstWeekday])];
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
    
    
    //[componentsToSubtract release];
    //format date
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM_dd_yyyy"];//format the date to the way it is on the CampusDish URL
    NSString *date = [f stringFromDate: beginningOfWeek];
    
    //[f release];
    
    
    
    //Find day of week in Integer form
    gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
    
    NSInteger weekday = [weekdayComponents weekday];
    // weekday 1 = Sunday for Gregorian calendar
    
    //[gregorian release];
    
    //Get Current Meal
    NSMutableArray *arrTemp = [[NSMutableArray alloc] init];//Temporary array used to fill the dictionary with Menu Items
    
    //This String will be entered as a key in the dictionary associated with which meal(breakfast/lunch/dinner)
    NSString* whatMeal = nil;
    
    //if its before breakfast or after dinner, show breakfast
    if ([today earlierDate:breakfastTime]==today||[today laterDate:dinnerTime]==today) {
        
        //breakfast.
        
        // 1
        //concat url string
        
        NSString *string1 = @"http://www.campusdish.com/en-US/CSSW/AustinCollege/Menus/DiningHallMenus.htm?LocationName=Dining%20Hall%20Menus&MealID=1&OrgID=222983&Date=";
        NSString *string2 = @"&ShowPrice=False&ShowNutrition=True";
        NSString *entireURL = [NSString stringWithFormat:@"%@%@%@", string1, date, string2];//date is the formatted date
        
        NSURL *tutorialsUrl = [NSURL URLWithString:entireURL];
        
        //get data from URL
        NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
        
        // 2 generate a Parser
        TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
        
        // 3 Concat a parse query getting the Menu Items for the given day
        string1 = @"//td[@class='menuBorder'][";
        string2 = @"]//td[@colspan='3']/a[@class='recipeLink']";
        entireURL = [NSString stringWithFormat:@"%@%d%@", string1, weekday, string2];//weekday is the Integer day of the week
        
        NSString *tutorialsXpathQueryString = entireURL;
        //queried HTML nodes are filled into this array
        NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        
        // 4
        //fill temporary array with meal item data
        for (TFHppleElement *element in tutorialsNodes) {
            //Create an object to store the data for each Menu Item
            Tutorial *tutorial = [[Tutorial alloc] init];
            [arrTemp addObject:tutorial];//Add the object to the temporary array
            tutorial.title = [[element firstChild] content];//Meal Title
            tutorial.url = [element objectForKey:@"href"];//Url to its Nutrition facts
        }
        whatMeal = @"Breakfast";//set the key to Breakfast
        
        
    }else if([today earlierDate:lunchTime]==today){//if its before lunch time:
        
        // 1 concat the URL string
        NSString *string1 = @"http://www.campusdish.com/en-US/CSSW/AustinCollege/Menus/DiningHallMenus.htm?LocationName=Dining%20Hall%20Menus&MealID=16&OrgID=222983&Date=";
        NSString *string2 = @"&ShowPrice=False&ShowNutrition=True";
        NSString *entireURL = [NSString stringWithFormat:@"%@%@%@", string1, date, string2];//date is formatted date
        NSURL *tutorialsUrl = [NSURL URLWithString:entireURL];
        
        
        NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
        
        // 2
        TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
        
        // 3 concat the parse query for Meal Item nodes
        string1 = @"//td[@class='menuBorder'][";
        string2 = @"]//td[@colspan='3']/a[@class='recipeLink']";
        entireURL = [NSString stringWithFormat:@"%@%d%@", string1, weekday, string2];//weekday is the Integer day of the week
        
        NSString *tutorialsXpathQueryString = entireURL;
        
        //Get Nodes containing Meal Items
        NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        
        // 4
        //fill temporary array with Meal Item data
        for (TFHppleElement *element in tutorialsNodes) {
            //Store Meal Item data into an object
            Tutorial *tutorial = [[Tutorial alloc] init];
            [arrTemp addObject:tutorial];//add object to temporary array
            tutorial.title = [[element firstChild] content];//Meal Item title
            tutorial.url = [element objectForKey:@"href"];//Link to nutrition info
            
            
        }
        whatMeal = @"Lunch";//set key to lunch
    }else if([today earlierDate:dinnerTime]==today){//if its before dinner time:
        //dinner.
        
        // 1 concat URL string
        NSString *string1 = @"http://www.campusdish.com/en-US/CSSW/AustinCollege/Menus/DiningHallMenus.htm?LocationName=Dining%20Hall%20Menus&MealID=17&OrgID=222983&Date=";
        NSString *string2 = @"&ShowPrice=False&ShowNutrition=True";
        NSString *entireURL = [NSString stringWithFormat:@"%@%@%@", string1, date, string2];//date is formatted date
        NSURL *tutorialsUrl = [NSURL URLWithString:entireURL];
        
        //get data from URL
        NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
        
        // 2 generate html parser
        TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
        
        // 3 concat parse query for Meal Item nodes
        string1 = @"//td[@class='menuBorder'][";
        string2 = @"]//td[@colspan='3']/a[@class='recipeLink']";
        entireURL = [NSString stringWithFormat:@"%@%d%@", string1, weekday, string2];//weekday is the formatted date
        
        NSString *tutorialsXpathQueryString = entireURL;
        
        //get Nodes for Meal Items
        NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        
        // 4
        //Fill temporary array with Meal Item data
        for (TFHppleElement *element in tutorialsNodes) {
            //Store Meal Item data in an object
            Tutorial *tutorial = [[Tutorial alloc] init];
            [arrTemp addObject:tutorial];//add object to temporary array
            tutorial.title = [[element firstChild] content];//Meal item title
            tutorial.url = [element objectForKey:@"href"];//link to nutrition page
        }
        
        whatMeal = @"Dinner";//set key to dinner
    }
    //configure dictionary
    NSDictionary *temp =[[NSDictionary alloc] initWithObjectsAndKeys:arrTemp,whatMeal,nil];
    
    //set color of navigationBar
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:178.0/255.0 blue:0.0/255.0 alpha:0.0];
    
    //set dictionary to created Dictionary
    self.tableContents =temp;
    //[temp release];
    
    //configure keys (breakfast/lunch/dinner)
    self.sortedKeys = [[NSArray alloc] initWithObjects: whatMeal, nil];
    
    //[arrTemp release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 1;
    
    return [self.sortedKeys count];
    
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return [self.sortedKeys objectAtIndex:section];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *listData =[self.tableContents objectForKey:[self.sortedKeys objectAtIndex:section]];
    return [listData count];
}

// Configure Cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //retrieve data from dictionary
    NSArray *listData =[self.tableContents objectForKey:[self.sortedKeys objectAtIndex:[indexPath section]]];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"];//this refers to the cell in UIBuilder
    
    //If cell is null allocate a cell with identifier from UIBuilder
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSUInteger row = [indexPath row];
    
    //get data for the object at the given row and set label of Cell with Meal data
    Tutorial *thisTutorial = [listData objectAtIndex:row];
    cell.textLabel.text = thisTutorial.title;
    cell.detailTextLabel.text = thisTutorial.url;
    
    //populate cell
    return cell;
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
 Response to segue event created in UIBuilder
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //If cell is selected, send the detailView URL info (to load nutrition info) 
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        DetailViewController* destVC =
        (DetailViewController*)segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //get data from dictionary
        NSArray *listData =[self.tableContents objectForKey:[self.sortedKeys objectAtIndex:[indexPath section]]];
        NSUInteger row = [indexPath row];
        Tutorial *element = [listData objectAtIndex:row];//create temporary handle on object containing Meal Data
        NSString *urlString = element.url;
        //urlString = @"http://www.campusdish.com/en-US/CSSW/AustinCollege/Menus/rda.aspx?RCN=m5768&MI=1731&RN=TATER%20TOTS";
        //NSURL *url = [NSURL URLWithString: urlString];
        NSURL *url = [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        destVC.detailItem = url;//send the destination controller the URL
        destVC.navigationItem.title = @"Nutrition";//Title the page
    } else if ([[segue identifier] isEqualToString:@"showDate"]) {
        //If date is selected, send dateView date info
        NSDate *chosenDate = [self.datePicker date];
        DateViewController *myViewController = (DateViewController*)segue.destinationViewController;
        myViewController.title = [chosenDate description];
        myViewController.todayMain = chosenDate;
        
    }
    
    
}

- (IBAction)valueChanged:(id)sender {
    //Navigation logic may go here. Create and push another view controller.
    /*
     NSDate *chosenDate = [self.datePicker date];
     DateViewController *myViewController = [[DateViewController alloc] init];
     myViewController.title = [chosenDate description];
     myViewController.todayMain = chosenDate;
     
     //to push the UIView.
     [self.navigationController pushViewController:myViewController animated:YES];
     */
    if ([self.view viewWithTag:9]) {
        return;
    }
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 320, 216);
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    darkView.alpha = 0;
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)];
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];
    /*
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    datePicker.tag = 10;
    [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    */
    
    UIPickerView *dPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    dPicker.tag = 10;
    [dPicker setDataSource:self];
    [dPicker setDelegate:self];
    dPicker.showsSelectionIndicator = YES;
    //dPicker
    //[dPicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:dPicker];
    
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)];
    
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    dPicker.frame = datePickerTargetFrame;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
    
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
    
    //NSLog([todayMain description]);
    [self setDictionary:todayMain];
    [self.tableView reloadData];
}

// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return 7;
    }
    return 3;
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(component == 0){
    if (row == 0) {
        return @"Today";
    }else if (row == 1) {
        return @"Tomorrow";
    }else if (row == 2){
        NSDate *now = [NSDate date];
        int daysToAdd = 2;
        NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        return [self dayOfWeek:newDate1];
    }else if (row == 3){
        NSDate *now = [NSDate date];
        int daysToAdd = 3;
        NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        return [self dayOfWeek:newDate1];
    }else if (row == 4){
        NSDate *now = [NSDate date];
        int daysToAdd = 4;
        NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        return [self dayOfWeek:newDate1];
    }else if (row == 5){
        NSDate *now = [NSDate date];
        int daysToAdd = 5;
        NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        return [self dayOfWeek:newDate1];
    }else if (row == 6){
        NSDate *now = [NSDate date];
        int daysToAdd = 6;
        NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        return [self dayOfWeek:newDate1];
    }
    }else if(component == 1){
        if(row == 0){
            return @"Breakfast";
        }else if(row == 1){
            return @"Lunch";
        }else if(row == 2){
            return @"Dinner";
        }
    }
    return @"hello";
}

//finds the string day of the week value
-(NSString *)dayOfWeek:(NSDate*)theDay{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:theDay];
    
    NSInteger weekday = [weekdayComponents weekday];
    // weekday 1 = Sunday for Gregorian calendar
    
    if (weekday == 1) {
        return @"Sunday";
    }else if(weekday == 2){
        return @"Monday";
    }else if(weekday == 3){
        return @"Tuesday";
    }else if(weekday == 4){
        return @"Wednesday";
    }else if(weekday == 5){
        return @"Thursday";
    }else if(weekday == 6){
        return @"Friday";
    }else if(weekday == 7){
        return @"Saturday";
    }
    
    return @"Sunday";
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //NSLog(@"You selected this: %@", [dataArray objectAtIndex: row]);
    if(component == 0){
    if (row == 0) {
        NSDate *now = [[NSDate date] copy];
        todayMain = now;
    }else if (row == 1) {
        NSDate *now = [[NSDate date] copy];
        int daysToAdd = 1;
        NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        todayMain = newDate1;
    }else if (row == 2){
        NSDate *now = [[NSDate date] copy];
        int daysToAdd = 2;
        NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        todayMain = newDate1;
    }else if (row == 3){
        NSDate *now = [[NSDate date] copy];
        int daysToAdd = 3;
        NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        todayMain = newDate1;
    }else if (row == 4){
        NSDate *now = [[NSDate date] copy];
        int daysToAdd = 4;
        NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        todayMain = newDate1;
    }else if (row == 5){
        NSDate *now = [[NSDate date] copy];
        int daysToAdd = 5;
        NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        todayMain = newDate1;
    }else if (row == 6){
        NSDate *now = [[NSDate date] copy];
        int daysToAdd = 6;
        NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        todayMain = newDate1;
    }
    }else if(component == 1){
        if (row == 0) {
            NSCalendar *gregorianTime = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
            NSDateComponents *components1 = [gregorianTime components: NSUIntegerMax fromDate: todayMain];//components for breakfast (7am)
            [components1 setHour: 7];
            [components1 setMinute: 0];
            
            todayMain = [gregorianTime dateFromComponents: components1];
        }else if (row == 1) {
            NSCalendar *gregorianTime = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
            NSDateComponents *components1 = [gregorianTime components: NSUIntegerMax fromDate: todayMain];//components for lunch (11am)
            [components1 setHour: 11];
            [components1 setMinute: 0];
            
            todayMain = [gregorianTime dateFromComponents: components1];
        }else if (row == 2){
            NSCalendar *gregorianTime = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
            NSDateComponents *components1 = [gregorianTime components: NSUIntegerMax fromDate: todayMain];//components for dinner (5pm)
            [components1 setHour: 17];
            [components1 setMinute: 0];
            
            todayMain = [gregorianTime dateFromComponents: components1];
        }
    }
}

/*
 Deallocate member variables
 
- (void)dealloc
{
    [_datePicker release];
    
    [tableContents release];
    [sortedKeys release];
    [todayMain release];
    
    [_detailViewController release];
    [_objects release];
    [super dealloc];
}
 */
@end
