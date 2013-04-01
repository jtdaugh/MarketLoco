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

@synthesize title, description, priceLabel, pic, container, contactSeller, item, callNotText;

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
    
    if (callNotText && callNotText == [NSNumber numberWithBool:YES]) {
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:[item objectForKey:@"postedBy"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    } else {
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
}


-(void)displaySMSComposerSheet
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        [item fetchIfNeeded];
        controller.body = [NSString stringWithFormat:@"I'm interested in \"%@.\" ", [item objectForKey:@"title"]];
        controller.recipients = [NSArray arrayWithObject:[item objectForKey:@"postedBy"]];
        controller.messageComposeDelegate = [APP_DELEGATE viewController];
        [[APP_DELEGATE viewController] presentModalViewController:controller animated:YES];
    }
}


@end
