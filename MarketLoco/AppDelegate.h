//
//  AppDelegate.h
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/15/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "Mixpanel.h"
#define APP_DELEGATE (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define MIXPANEL_TOKEN @"69253db17590ba31bc8ef5dcbbecfdc8"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) ViewController *viewController;

@end
