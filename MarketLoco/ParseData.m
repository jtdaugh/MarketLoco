//
//  ParseData.m
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/19/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import "ParseData.h"

@implementation ParseData

@synthesize categories, networks;

+(id) sharedParseData {
    static ParseData *sharedJTDParseData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken , ^{
        sharedJTDParseData = [[self alloc] init];
    });
    return sharedJTDParseData;
}

-(id) init {
    if (self = [super init]) {
        categories = [[NSMutableArray alloc] init];
        networks = [[NSMutableArray alloc] init];
        
        [self getCategoriesFromParse];
        [self getNetworksFromParse];
    }
    return self;
}


-(void) getCategoriesFromParse {
    PFQuery *query = [PFQuery queryWithClassName:@"Categories"];
    [query addAscendingOrder:@"order"];
    [query whereKeyDoesNotExist:@"parentCategory"];
    [query setLimit:20];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d categories", objects.count);
            categories = objects;
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void) getNetworksFromParse {
    PFQuery *query = [PFQuery queryWithClassName:@"Networks"];
    [query addAscendingOrder:@"name"];
    [query whereKeyDoesNotExist:@"dev"];
    [query setLimit:20];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d networks", objects.count);
            networks = objects;
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
 