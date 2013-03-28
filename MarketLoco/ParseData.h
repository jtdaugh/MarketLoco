//
//  ParseData.h
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/19/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
//#import "AppDelegate.h"

@interface ParseData : NSObject

@property (nonatomic, retain) NSMutableArray *categories;
@property (nonatomic, retain) NSMutableArray *networks;

+ (id)sharedParseData;

-(void) getCategoriesFromParse;
-(void) getNetworksFromParse;

@end
