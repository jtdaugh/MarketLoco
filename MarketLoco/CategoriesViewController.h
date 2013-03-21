//
//  CategoriesViewController.h
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/19/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import <Parse/Parse.h>
#import "ParseData.h"
#import "AppDelegate.h"

@interface CategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *categoriesTable;

@end
