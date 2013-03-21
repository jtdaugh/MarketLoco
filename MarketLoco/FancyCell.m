//
//  FancyCell.m
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/19/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import "FancyCell.h"
#import "ViewController.h"

@implementation FancyCell

@synthesize title, description, priceLabel, pic, container, contactSeller, item;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(IBAction)contactSellerClicked {
    [item fetchIfNeeded];
    [item incrementKey:@"mobileContact"];
    [item saveInBackground];
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    
    if (messageClass != nil) {
        [self displaySMSComposerSheet];
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

-(void)displaySMSComposerSheet
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = @"I saw your item on MarketLoco. I'd like to buy it.";
        controller.recipients = [NSArray arrayWithObject:[item objectForKey:@"createdBy"]];
        controller.messageComposeDelegate = [APP_DELEGATE viewController];
        [[APP_DELEGATE viewController] presentModalViewController:controller animated:YES];
    }
    //do nothing (OS will alert user of error)
}






@end
