//
//  MasterViewController.m
//  Kangaroo Menu
//
//  Created by Dev Mohanty on 10/24/12.
//  Copyright (c) 2012 Dev Mohanty. All rights reserved.
//

#import "DateViewController.h"



#import "TFHpple.h"
#import "Tutorial.h"
/*
 When a user selects a date via the MasterView, we segue to this ViewController
 */
@interface DateViewController () {
    NSMutableArray *_objects;
    
    NSDictionary *tableContents;//meal items
    NSArray *sortedKeys;// breakfast/lunch/dinner
    
    NSDate *todayMain;//chosen date/time
    
}
@end

@implementation DateViewController
@synthesize tableContents;
@synthesize sortedKeys;
@synthesize todayMain;


- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

/*
 set dictionary with given Date when viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDictionary: todayMain];//fill dictionary with meal items for day
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
}

/*
 implementation of setDictionary
 */
-(void)setDictionary:(NSDate*)today
{
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
    [f setDateFormat:@"MM_dd_yyyy"];//format to the CampusDish URL
    NSString *date = [f stringFromDate: beginningOfWeek];//get date string for Sunday
    
    [f release];
    //[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    /*self.navigationItem.leftBarButtonItem = self.editButtonItem;
     
     UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
     self.navigationItem.rightBarButtonItem = addButton;
     */
    
    
    
    //Find day of week in Integer form
    gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
    
    NSInteger weekday = [weekdayComponents weekday];
    // weekday 1 = Sunday for Gregorian calendar
    
    [gregorian release];
    
    //populate breakfast items array.
    NSMutableArray *arrTemp1 = [[NSMutableArray alloc] init];
    
    // 1
    //concat url string with first sunday's date string
    
    NSString *string1 = @"http://www.campusdish.com/en-US/CSSW/AustinCollege/Menus/DiningHallMenus.htm?LocationName=Dining%20Hall%20Menus&MealID=1&OrgID=222983&Date=";
    NSString *string2 = @"&ShowPrice=False&ShowNutrition=True";
    NSString *entireURL = [NSString stringWithFormat:@"%@%@%@", string1, date, string2];
    
    NSURL *tutorialsUrl = [NSURL URLWithString:entireURL];
    
    //Get data from URL
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
    
    // 2 Create parser for data
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    
    // 3 concat parse string with integer value of day to get meal item nodes
    string1 = @"//td[@class='menuBorder'][";
    string2 = @"]//td[@colspan='3']/a[@class='recipeLink']";
    entireURL = [NSString stringWithFormat:@"%@%d%@", string1, weekday, string2];//weekday is integer value of day
    
    NSString *tutorialsXpathQueryString = entireURL;
    
    //parse with query string and receive array of meal item nodes
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    // 4
    //fill array for breakfast with Meal item data 
    for (TFHppleElement *element in tutorialsNodes) {
        //create object to store Meal Item data
        Tutorial *tutorial = [[Tutorial alloc] init];
        [arrTemp1 addObject:tutorial];//add object to lunch array
        tutorial.title = [[element firstChild] content];//Get meal title from the node
        tutorial.url = [element objectForKey:@"href"];//Get nutrition page URL from node
    }
    
    
    //populate lunch items array.
    NSMutableArray *arrTemp2 = [[NSMutableArray alloc] init];
    
    // 1 concat url string with formatted day string
    string1 = @"http://www.campusdish.com/en-US/CSSW/AustinCollege/Menus/DiningHallMenus.htm?LocationName=Dining%20Hall%20Menus&MealID=16&OrgID=222983&Date=";
    string2 = @"&ShowPrice=False&ShowNutrition=True";
    entireURL = [NSString stringWithFormat:@"%@%@%@", string1, date, string2];//date is formatted date string 
    tutorialsUrl = [NSURL URLWithString:entireURL];
    
    //get data with URL
    tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
    
    // 2 create parser for URL
    tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    
    // 3 concat parse query string
    string1 = @"//td[@class='menuBorder'][";
    string2 = @"]//td[@colspan='3']/a[@class='recipeLink']";
    entireURL = [NSString stringWithFormat:@"%@%d%@", string1, weekday, string2]; //weekday is integer value of day of week
    
    tutorialsXpathQueryString = entireURL;
    //get Meal Item nodes using query string
    tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    // 4
    //put meal items in temporary lunch array
    for (TFHppleElement *element in tutorialsNodes) {
        //Store data in for given meal item in object
        Tutorial *tutorial = [[Tutorial alloc] init];
        [arrTemp2 addObject:tutorial];//add object to temporary array
        tutorial.title = [[element firstChild] content];//set Meal title
        tutorial.url = [element objectForKey:@"href"];//set URL of Nutrition page
        
        
    }
    
    //populate dinner items array
    NSMutableArray *arrTemp3 = [[NSMutableArray alloc] init];
    
    // 1 concat URL string with formatted date string
    string1 = @"http://www.campusdish.com/en-US/CSSW/AustinCollege/Menus/DiningHallMenus.htm?LocationName=Dining%20Hall%20Menus&MealID=17&OrgID=222983&Date=";
    string2 = @"&ShowPrice=False&ShowNutrition=True";
    entireURL = [NSString stringWithFormat:@"%@%@%@", string1, date, string2];//date is formatted date string
    tutorialsUrl = [NSURL URLWithString:entireURL];
    
    //get data from URL 
    tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
    
    // 2 create parser for HTML data
    tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    
    // 3 concat parse query using integer value for day of week
    //tutorialsXpathQueryString = @"//td[@class='menuBorder'][5]//td[@colspan='3']/a[@class='recipeLink']";
    string1 = @"//td[@class='menuBorder'][";
    string2 = @"]//td[@colspan='3']/a[@class='recipeLink']";
    entireURL = [NSString stringWithFormat:@"%@%d%@", string1, weekday, string2]; //weekday is integer value for day of the week 
    
    tutorialsXpathQueryString = entireURL;
    
    //get Meal Item nodes with the query string
    tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    // 4
    //fill temporary dinner array with Meal Item data
    for (TFHppleElement *element in tutorialsNodes) {
        //Store data for Meal Item in object
        Tutorial *tutorial = [[Tutorial alloc] init];
        [arrTemp3 addObject:tutorial];//add object to temporary dinner array
        tutorial.title = [[element firstChild] content];//set the Meal title
        tutorial.url = [element objectForKey:@"href"];//set the nutrition page info URL
    }
    
    //create dictionary with breakfast/lunch/dinner arrays
    NSDictionary *temp =[[NSDictionary alloc] initWithObjectsAndKeys:arrTemp1,@"Breakfast",arrTemp2, @"Lunch",arrTemp3,@"Dinner",nil];
    
    //set navigation bar color
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:178.0/255.0 blue:0.0/255.0 alpha:0.0];
    
    //set dictionary with created dictionary
    self.tableContents =temp;
    [temp release];
    
    //alloc keys
    self.sortedKeys = [[NSArray alloc] initWithObjects: @"Breakfast",@"Lunch",@"Dinner", nil];
    
    [arrTemp1 release];
    [arrTemp2 release];
    [arrTemp3 release];

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

// Render a Cell

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get meal data from dicitonary;
    NSArray *listData =[self.tableContents objectForKey:[self.sortedKeys objectAtIndex:[indexPath section]]];//get data from dictionary
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"DateCell"];//Identifier from UIBuilder
    
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DateCell"] autorelease];//create cell to be rendered
         
    }
    
    NSUInteger row = [indexPath row];
    
    Tutorial *thisTutorial = [listData objectAtIndex:row];//get Meal Item Object
    cell.textLabel.text = thisTutorial.title;//set Meal title
    cell.detailTextLabel.text = thisTutorial.url;//set URL for nutrition page
    
    //return cell to be rendered
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
 Handle segue event
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if a cell is selected, send Meal Item's Nutrition Page URL to detail page
    if ([[segue identifier] isEqualToString:@"showDateDetail"]) {
        DetailViewController* destVC =
        (DetailViewController*)segue.destinationViewController;//destination is detailViewController
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray *listData =[self.tableContents objectForKey:[self.sortedKeys objectAtIndex:[indexPath section]]];//get Meal Items from dictionary
        NSUInteger row = [indexPath row];
        Tutorial *element = [listData objectAtIndex:row];//get Meal Item Object
        NSString *urlString = element.url;//get URL to nutrition page of Meal Item
        NSURL *url = [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        
        destVC.detailItem = url;//set URL on detailView
        destVC.navigationItem.title = @"Nutrition";//set navigation bar title
    }
    
    
}

- (IBAction)valueChanged:(id)sender {
    /*todayMain = [self.datePicker date];
    [self setDictionary: todayMain];
    [[self tableView] reloadData];
    
    [[self tableView]setNeedsDisplay];
    
    NSLog(@"yoyo%@",[todayMain description]);
     */
}

/*
 Dealloc member variables
 */
- (void)dealloc
{
    [_datePicker release];
    
    [tableContents release];
    [sortedKeys release];
    [todayMain release];
    
    [_detailViewController release];
    //[_objects release];
    [super dealloc];
}
@end
