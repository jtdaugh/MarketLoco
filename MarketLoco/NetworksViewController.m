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
    [APP_DELEGATE setNetworkViewController:self];
    [self.slidingViewController setAnchorLeftPeekAmount:40.0f];
    self.slidingViewController.underRightWidthLayout = ECFullWidth;

	// Do any additional setup after loading the view.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[ParseData sharedParseData] networks] count] + 1;
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
    [cell.textLabel setTextColor:[UIColor colorWithRed:250 green:250 blue:250 alpha:1]];
    if (indexPath.row < [[[ParseData sharedParseData] networks] count]) {
    
        PFObject *object = [[[ParseData sharedParseData] networks] objectAtIndex:indexPath.row];
        NSString *title = [object objectForKey:@"longName"];
        [cell.textLabel setText:title];
    } else {
        [cell.textLabel setText:@"+ Add Your Campus"];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (indexPath.row < [[[ParseData sharedParseData] networks] count]) {

        PFObject *selected = [[[ParseData sharedParseData] networks] objectAtIndex:indexPath.row];
        NSString *selectedNetwork = [selected objectForKey:@"namespace"];
        [[NSUserDefaults standardUserDefaults] setObject:selectedNetwork forKey:@"network"];
        [[NSUserDefaults standardUserDefaults] setObject:[selected objectForKey:@"name"] forKey:@"networkName"];
        [[APP_DELEGATE viewController] pullNewestItemsForNetwork:selectedNetwork andCategory:@"All Items"];
        [[[APP_DELEGATE viewController] itemArray] removeAllObjects];
        [[[APP_DELEGATE viewController] itemPics] removeAllObjects];
        [[APP_DELEGATE viewController] setEndResultsText:@"Loading..."];
        [[[APP_DELEGATE viewController] tbView] reloadData];
        [[[APP_DELEGATE viewController] tbView] scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:[NSString stringWithFormat:@"Picked School: %@", selectedNetwork]];
        [self.slidingViewController resetTopView];
    } else{
        Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
        
        if (messageClass != nil) {
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            if([MFMessageComposeViewController canSendText])
            {
                controller.body = [NSString stringWithFormat:@"I want Loco on my campus!"];
                controller.recipients = [NSArray arrayWithObject:@"3107753248"];
                controller.messageComposeDelegate = [APP_DELEGATE viewController];
                [[APP_DELEGATE viewController] presentModalViewController:controller animated:YES];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Sorry!"
                                  message: @"You cannot send this message from this device."
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
