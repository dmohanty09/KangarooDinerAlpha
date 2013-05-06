//
//  DetailViewController.m
//  KangarooDiner
//
//  Created by Dev Mohanty on 11/1/12.
//  Copyright (c) 2012 Dev Mohanty. All rights reserved.
//

#import "DetailViewController.h"
/*
 This Class loads the webView showing the nutrition facts of a given food item.
 */
@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSURL*)newDetailItem
{
    if (_detailItem != newDetailItem) {
        //[_detailItem release];
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Set descriptionlabel to detailItem's description.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

/*
 Load webView with URL (given via segue)
 */
- (void)viewWillAppear:(BOOL)animated {
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.detailItem];
    
    [self.webView loadRequest:requestObj];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

/*
 Deallocate member variables
 
- (void)dealloc
{
    [_detailItem release];
    [_detailDescriptionLabel release];
    [_webView release];
    [_masterPopoverController release];
    [super dealloc];
}
 */
@end
