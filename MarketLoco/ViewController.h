//
//  ViewController.h
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/15/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "FancyCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "ParseData.h"
#import "ECSlidingViewController.h"
#import "NetworksViewController.h"
#import "CategoriesViewController.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate> {
    bool currentlyLoadingMore;
    bool endResults;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic,strong)CLLocation *userLocation;
@property (nonatomic, strong) IBOutlet UITableView *tbView;
@property (strong,nonatomic) NSMutableArray *itemArray;
@property (nonatomic, retain) NSMutableArray *itemPics;
@property (strong,nonatomic) NSMutableArray *filteredItemArray;
@property (nonatomic, strong) NSString *network;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) FancyCell *cellForReference;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *networkButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *categoryButton;
@property (nonatomic, strong) IBOutlet UINavigationItem *locoBar;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSString *networkName;
@property (nonatomic, strong) NSString *endResultsText;


-(void)pullNewestItemsForNetwork:(NSString *) newNetwork andCategory:(NSString *) newCategory;
-(void)addItemsToBottomFromIndex:(int)startIndex;
-(void)getMoreObjectsWithQuery:(PFQuery *)query andStartIndex:(int) startIndex;
-(void)geoQueryForNetwork;
-(void)makeBarPretty;
-(CGFloat)heightForFancyCellAtRow:(NSInteger)row;
-(CGFloat)heightForEndOfResultsRow;
-(UITableViewCell *)fancyCellAtRow:(NSInteger)row;
-(UITableViewCell *)endOfResultsCell;

- (IBAction)revealNetworks:(id)sender;
- (IBAction)revealCategories:(id)sender;


@end
