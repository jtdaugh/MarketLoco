//
//  CategoriesViewController.m
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/19/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import "CategoriesViewController.h"

@interface CategoriesViewController ()

@property (nonatomic, assign) CGFloat peekRightAmount;

@end

@implementation CategoriesViewController

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
	self.peekRightAmount = 40.0f;
    [self.slidingViewController setAnchorLeftPeekAmount:self.peekRightAmount];
    self.slidingViewController.underRightWidthLayout = ECVariableRevealWidth;

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
