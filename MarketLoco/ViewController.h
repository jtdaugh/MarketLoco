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

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic,strong)CLLocation *userLocation;
@property (nonatomic, strong) IBOutlet UITableView *tbView;
@property (strong,nonatomic) NSMutableArray *itemArray;
@property (nonatomic, retain) NSMutableArray *itemPics;
@property (strong,nonatomic) NSMutableArray *filteredItemArray;
@property (nonatomic, strong) NSString *network;
@property (nonatomic, strong) FancyCell *cellForReference;

-(void) pullNewestItems;
-(void)addItemsToBottomFromIndex:(int)startIndex;

@end
