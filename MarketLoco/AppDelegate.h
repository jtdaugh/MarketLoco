//
//  AppDelegate.h
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/15/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#define APP_DELEGATE (AppDelegate *)[[UIApplication sharedApplication] delegate]

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) ViewController *viewController;

@end
