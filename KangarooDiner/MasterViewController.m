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
}

//set the dictionary when viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    [gregorianTime release];
    
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
    
    
    [componentsToSubtract release];
    //format date
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM_dd_yyyy"];//format the date to the way it is on the CampusDish URL
    NSString *date = [f stringFromDate: beginningOfWeek];
    
    [f release];
    
    
    
    //Find day of week in Integer form
    gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
    
    NSInteger weekday = [weekdayComponents weekday];
    // weekday 1 = Sunday for Gregorian calendar
    
    [gregorian release];
    
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
    [temp release];
    
    //configure keys (breakfast/lunch/dinner)
    self.sortedKeys = [[NSArray alloc] initWithObjects: whatMeal, nil];
    
    [arrTemp release];
    
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
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
}

/*
 Deallocate member variables
 */
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
@end
