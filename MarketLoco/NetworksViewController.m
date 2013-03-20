//
//  MenuViewController.m
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/19/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import "NetworksViewController.h"

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
    [[self networkTable]setDataSource:self];
    [[self networkTable]setDelegate:self];
    
    [self.slidingViewController setAnchorLeftPeekAmount:-40.0f];
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
    NSString *title = [object objectForKey:@"name"];
    [cell.textLabel setText:title];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    //do nothing
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
