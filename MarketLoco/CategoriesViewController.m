//
//  CategoriesViewController.m
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/19/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import "CategoriesViewController.h"
#import "ViewController.h"

@interface CategoriesViewController ()

@property (nonatomic, assign) CGFloat peekRightAmount;

@end

@implementation CategoriesViewController

@synthesize categoriesTable;

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
    [self.categoriesTable setDataSource:self];
	[self.categoriesTable setDelegate:self];
    self.peekRightAmount = 40.0f;
    [self.slidingViewController setAnchorRightPeekAmount:self.peekRightAmount];
    self.slidingViewController.underLeftWidthLayout = ECVariableRevealWidth;

    // Do any additional setup after loading the view.
}






- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[ParseData sharedParseData] categories] count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"categoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    NSString *title;
    if (indexPath.row > 0) {
        PFObject *object = [[[ParseData sharedParseData] categories] objectAtIndex:indexPath.row - 1];
        title = [object objectForKey:@"name"];
    } else {
        title = @"All Items";
    }
    [cell.textLabel setText:title];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    NSString *title;
    if (indexPath.row == 0) {
        title = @"All Items";
    } else {
        title = [[[[ParseData sharedParseData] categories] objectAtIndex:indexPath.row - 1] objectForKey:@"name"];
    }
    NSString *tempNetwork = [[APP_DELEGATE viewController] network];
    if (!tempNetwork) tempNetwork = @"umich";
    [[APP_DELEGATE viewController] pullNewestItemsForNetwork:tempNetwork andCategory:title];
    [[[APP_DELEGATE viewController] tbView] scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];

    [self.slidingViewController resetTopView];
    
    //do nothing
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
