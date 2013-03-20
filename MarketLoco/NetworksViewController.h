//
//  NetworksViewController.h
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/19/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import <Parse/Parse.h>
#import "ParseData.h"

@interface NetworksViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *networkTable;

@end
