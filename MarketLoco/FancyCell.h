//
//  FancyCell.h
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/19/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Parse/Parse.h>
//#import "AppDelegate.h"

@interface FancyCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *description;
@property (nonatomic, strong) IBOutlet UIImageView *pic;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) IBOutlet UIView *container;
@property (nonatomic, strong) IBOutlet UIButton *contactSeller;
@property (nonatomic, strong) PFObject *item;
@property (nonatomic, strong) NSNumber *callNotText;

-(IBAction)contactSellerClicked;
-(void)displaySMSComposerSheet;

@end
