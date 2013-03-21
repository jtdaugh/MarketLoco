//
//  MenuViewController.m
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/19/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import "NetworksViewController.h"
#import "ViewController.h"

@interface NetworksViewController ()

@end


@implementation NetworksViewController

@synthesize networkTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.slidingViewController setAnchorLeftPeekAmount:40.0f];
    self.slidingViewController.underRightWidthLayout = ECFullWidth;

	// Do any additional setup after loading the view.
}






- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[ParseData sharedParseData] networks] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"networkCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    PFObject *object = [[[ParseData sharedParseData] networks] objectAtIndex:indexPath.row];  
    NSString *title = [object objectForKey:@"longName"];
    [cell.textLabel setText:title];
    [cell.textLabel setTextColor:[UIColor colorWithRed:250 green:250 blue:250 alpha:1]];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    PFObject *selected = [[[ParseData sharedParseData] networks] objectAtIndex:indexPath.row];
    NSString *selectedNetwork = [selected objectForKey:@"namespace"];
    [[NSUserDefaults standardUserDefaults] setObject:selectedNetwork forKey:@"network"];
    [[NSUserDefaults standardUserDefaults] setObject:[selected objectForKey:@"name"] forKey:@"networkName"];
    [[APP_DELEGATE viewController] pullNewestItemsForNetwork:selectedNetwork andCategory:@"All Items"];
    [[[APP_DELEGATE viewController] tbView] scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:[NSString stringWithFormat:@"Picked School: %@", selectedNetwork]];
;
    [self.slidingViewController resetTopView];

}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
