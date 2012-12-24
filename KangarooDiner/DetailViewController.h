//
//  DetailViewController.h
//  Kangaroo Menu
//
//  Created by Dev Mohanty on 10/24/12.
//  Copyright (c) 2012 Dev Mohanty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"
/*
 This defines the properties for the detailView (which displays a webView)
 */
@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) NSURL *detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end
