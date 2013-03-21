//
//  ViewController.m
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/15/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import "ViewController.h"

#define GAP_BETWEEN_CELLS 20
#define GAP_BETWEEN_TEXTS 10
#define BOX_WIDTH 280
#define BOX_PADDING 15
#define MAX_TITLE_WIDTH 250
#define MAX_DESCRIPTION_WIDTH 250
#define MAX_TITLE_HEIGHT 200
#define MAX_DESCRIPTION_HEIGHT 1000
#define IMAGE_HEIGHT 200
#define IMAGE_WIDTH 280
#define MAX_PRICE_WIDTH 100
#define PRICE_HEIGHT 40
#define PRICE_PADDING 30
#define CORNER_RADIUS 0
#define BORDER_THICKNESS 2
#define CONTACT_HEIGHT 40
#define CONTACT_WIDTH 160

//int h = imageHeight + titleSize.height + descriptionSize.height + GAP_BETWEEN_CELLS + (2 * GAP_BETWEEN_TEXTS) + BOX_PADDING + CONTACT_HEIGHT;



@interface ViewController ()

@end

@implementation ViewController

@synthesize tbView,filteredItemArray,itemArray,locationManager,userLocation, itemPics,
network, cellForReference, category, networkButton, categoryButton, locoBar, networkName, spinner;

-(void) makeBarPretty {
    
     UIView *locoBarView = [[UIView alloc] initWithFrame:CGRectMake(80, 10, 70, 20)];
     UIImageView *locoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locologo.png"]];
    [locoBarView addSubview:locoView];
    [locoBar setTitleView:locoBarView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Opened iOS App"];
    [spinner setHidden:NO];
    cellForReference = [[FancyCell alloc] init];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FancyView" owner:nil options:nil];
    
    for(id currentObject in topLevelObjects)
    {
        if([currentObject isKindOfClass:[FancyCell class]])
        {
            cellForReference = (FancyCell *)currentObject;
            break;
        }
    }
    
    [ParseData sharedParseData];
    [self makeBarPretty];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setViewController:self];
    self.tbView.delegate = self;
    self.tbView.dataSource = self;
    NSString *prevNetwork = [[NSUserDefaults standardUserDefaults]objectForKey:@"network"];
    networkName = [[NSUserDefaults standardUserDefaults]objectForKey:@"networkName"];

    if (!prevNetwork) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager startUpdatingLocation];
        locationManager.delegate = self;
    } else {
        [self pullNewestItemsForNetwork:prevNetwork andCategory:@"All Items" ];
    }
   
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[NetworksViewController class]]) {
        self.slidingViewController.underRightViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Networks"];
    }
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[CategoriesViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Categories"];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location: %@", [newLocation description]);
    userLocation = newLocation;
    [locationManager stopUpdatingLocation];
    [self geoQueryForNetwork];
}

-(void)geoQueryForNetwork {
    PFQuery *query = [PFQuery queryWithClassName:@"Networks"];
    // Interested in locations near user.
    PFGeoPoint *myGeoPoint = [PFGeoPoint geoPointWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    [query whereKeyDoesNotExist:@"dev"];
    [query whereKey:@"location" nearGeoPoint:myGeoPoint];
    // Limit what could be a lot of points.
    PFObject *networkObj = [query getFirstObject];
    NSString * locNetwork = [networkObj objectForKey:@"namespace"];
    networkName = [networkObj objectForKey:@"name"];
    [[NSUserDefaults standardUserDefaults]setObject:locNetwork forKey:@"network"];
    [[NSUserDefaults standardUserDefaults]setObject:networkName forKey:@"networkName"];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:[NSString stringWithFormat:@"Autolocated School: %@", locNetwork]];
    [self pullNewestItemsForNetwork:locNetwork andCategory:@"All Items"];
}


-(void)pullNewestItemsForNetwork:(NSString *) newNetwork andCategory:(NSString *) newCategory {

    if (!network || !category || !([network isEqualToString:newNetwork] && [category isEqualToString:newCategory])) {
 
        network = newNetwork;
        category = newCategory;
        networkName = [[NSUserDefaults standardUserDefaults] objectForKey:@"networkName"];
        [[self networkButton] setTitle:networkName];
        [[self categoryButton] setTitle:category];
        
        PFQuery *globalQuery = [PFQuery queryWithClassName:@"Listings"];
        [globalQuery whereKeyDoesNotExist:@"network"];
        
        
        PFQuery *localQuery = [PFQuery queryWithClassName:@"Listings"];
        [localQuery whereKey:@"network" equalTo:network];
        
        
                
        PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects: globalQuery, localQuery, nil]];
        [query orderByDescending:@"premiumListing"];
        [query addDescendingOrder:@"updatedAt"];
        if (![category isEqualToString:@"All Items"]) {
            [query whereKey:@"category" equalTo:category];
        }
        [query setLimit:30];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved the first %d listings.", objects.count);
                [spinner setHidden:YES];
                itemArray = objects;
                [tbView reloadData];
                itemPics = [NSMutableArray arrayWithCapacity:[itemArray count]];
                for(int i = 0; i < [itemArray count]; i++) [itemPics addObject: [NSNull null]];
                
                for (int i = 0; i < [itemArray count]; i++) {
                    dispatch_async(dispatch_get_global_queue(0,0), ^{
                        if ([[itemArray objectAtIndex:i] objectForKey:@"uploadedImage"] == [NSNumber numberWithBool:YES]) {
                            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [[itemArray objectAtIndex:i] objectForKey:@"picUrl"]]];
                            if ( data == nil )
                                return;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [itemPics replaceObjectAtIndex:i withObject:data];
//                                NSLog(@"added pic");
                                if (i <= 2) {
                                    [[self tbView] reloadData];
                                }
                            });
                        }
                    });
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

-(void)addItemsToBottomFromIndex:(int)startIndex {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Listings"];
    [query orderByDescending:@"updatedAt"];
    query.skip = startIndex;
    [query whereKey:@"network" equalTo:network];
    if (![category isEqualToString:@"All Items"]) {
        [query whereKey:@"category" equalTo:category];
    }
    [query setLimit:30];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number <= startIndex)
            return;
        else
            [self getMoreObjectsWithQuery:query andStartIndex:startIndex];
    }];    
}

-(void)getMoreObjectsWithQuery:(PFQuery *)query andStartIndex:(int) startIndex {
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d extra listings.", objects.count);
            [itemArray addObjectsFromArray:objects];
            [tbView reloadData];
            for(int i = 0; i < [objects count]; i++) [itemPics addObject: [NSNull null]];
            for (int i = 0; i < [objects count]; i++) {
                int realIndex = startIndex + i;
                dispatch_async(dispatch_get_global_queue(0,0), ^{
                    if ([[itemArray objectAtIndex:i] objectForKey:@"uploadedImage"] == [NSNumber numberWithBool:YES]) {
                        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [[itemArray objectAtIndex:realIndex] objectForKey:@"picUrl"]]];
                        if ( data == nil )
                            return;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [itemPics replaceObjectAtIndex:realIndex withObject:data];
//                            NSLog(@"added pic");
                        });
                    }
                });
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

//UITableViewMethods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *object = [itemArray objectAtIndex:[indexPath row]];

    int imageHeight = 0;
    NSNumber * img = [object objectForKey:@"uploadedImage"];
    if (img == [NSNumber numberWithBool:YES]) {
        imageHeight = IMAGE_HEIGHT;
    }
    
    NSString *descrip = [object objectForKey:@"description"];
    if ([descrip length] > 300) {
        descrip = [NSString stringWithFormat:@"%@...",[descrip substringToIndex:300]];
    }

    UIFont *daFont = [[self cellForReference] description].font;
    CGSize descriptionSize = [descrip sizeWithFont:daFont constrainedToSize:CGSizeMake(MAX_DESCRIPTION_WIDTH, MAX_DESCRIPTION_HEIGHT)
                                                                lineBreakMode:NSLineBreakByWordWrapping];
    NSString *price = @"$";
    NSString *tempPrice = [object objectForKey:@"price"];
    if (tempPrice != [NSNull null])
        price = [price stringByAppendingString:tempPrice];
    
    CGSize priceSize = [price sizeWithFont:[cellForReference priceLabel].font
                                                               constrainedToSize:CGSizeMake(MAX_PRICE_WIDTH, PRICE_HEIGHT)
                                                                   lineBreakMode:NSLineBreakByWordWrapping];
    
    
    int maxTitleWidth = MAX_TITLE_WIDTH;
    if (imageHeight == 0) {
        maxTitleWidth -= (priceSize.width + PRICE_PADDING + 5);
    }
    
    CGSize titleSize = [[object objectForKey:@"title" ] sizeWithFont:[cellForReference title].font
                                                        constrainedToSize:CGSizeMake(maxTitleWidth, MAX_TITLE_HEIGHT)
                                                        lineBreakMode:NSLineBreakByWordWrapping];
    
    int h = imageHeight + titleSize.height + descriptionSize.height + GAP_BETWEEN_CELLS + (2 * GAP_BETWEEN_TEXTS) + BOX_PADDING + CONTACT_HEIGHT;
    
//    NSLog(@"description Size- h:%f , w:%f", descriptionSize.height, descriptionSize.width);
//    NSLog(@"title Size- h:%f , w:%f", titleSize.height, titleSize.width);
//    NSLog(@"imageHeight:%d", imageHeight);
//    NSLog(@"Set row height: %d", h);
    return h;
}




// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"fancyCell";
    
    FancyCell *cell = (FancyCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
//        NSLog(@"\nNew Cell Made");
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FancyView" owner:nil options:nil];
        
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[FancyCell class]])
            {
                cell = (FancyCell *)currentObject;
                break;
            }
        }
    }
    PFObject *object = [itemArray objectAtIndex:[indexPath row]];
    NSData * imgData = [itemPics objectAtIndex:[indexPath row]];
    
    int imageHeight = 0;
    NSNumber *img = [object objectForKey:@"uploadedImage"];
    
    if (img == [NSNumber numberWithBool:YES]) {
        imageHeight = IMAGE_HEIGHT;
        if (imgData != [NSNull null]) {
            [[cell pic] setImage:[UIImage imageWithData:imgData]];
        } else {
            [[cell pic] setImage:[UIImage imageNamed:@"loading.gif"]];
        }
    }
    
    NSString *description = [object objectForKey:@"description"];
    if ([description length] > 300) {
        description = [NSString stringWithFormat:@"%@...",[description substringToIndex:300]];
    }

    NSString *title = [object objectForKey:@"title"];
    NSString *price = @"$";
    price = [price stringByAppendingString:[object objectForKey:@"price"]];
    
//    NSLog(@"Title: %@", title);
//    NSLog(@"Description: %@", description);

    
    [[cell title] setText:title];
    [[cell description] setText:description];
    [[cell priceLabel] setText:price];

    
    CGSize descriptionSize = [description sizeWithFont:[cell description].font
                                            constrainedToSize:CGSizeMake(MAX_DESCRIPTION_WIDTH, MAX_DESCRIPTION_HEIGHT)
                                            lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize priceSize = [price sizeWithFont:[cell priceLabel].font
                            constrainedToSize: CGSizeMake(MAX_PRICE_WIDTH, PRICE_HEIGHT)
                             lineBreakMode:NSLineBreakByWordWrapping];
    
    
    int maxTitleWidth = MAX_TITLE_WIDTH;
    if (imageHeight == 0) {
        maxTitleWidth -= (priceSize.width + PRICE_PADDING + 5);

    }
    
    
    CGSize titleSize = [title sizeWithFont:[cell title].font
                            constrainedToSize:CGSizeMake(maxTitleWidth, MAX_TITLE_HEIGHT)
                             lineBreakMode:NSLineBreakByWordWrapping];
  
//    NSLog(@"description Size- h:%f , w:%f", descriptionSize.height, descriptionSize.width);
//    NSLog(@"title Size- h:%f , w:%f", titleSize.height, titleSize.width);
//    NSLog(@"price Size- h:%f , w:%f", descriptionSize.height, descriptionSize.width);
//
//    NSLog(@"imageHeight:%d", imageHeight);
    
    int containerHeight = imageHeight + descriptionSize.height + titleSize.height + (GAP_BETWEEN_TEXTS * 2) + BOX_PADDING + CONTACT_HEIGHT;

    [[cell container] setFrame:CGRectMake((320-(BOX_WIDTH))/2,
                                          GAP_BETWEEN_CELLS,
                                          BOX_WIDTH,
                                          containerHeight)];
    
    [cell container].layer.cornerRadius = CORNER_RADIUS;
    [cell container].layer.borderWidth = BORDER_THICKNESS;
    [cell container].layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.4 alpha:.25].CGColor;
    
    
    [cell container].layer.masksToBounds = YES;
    
    [[cell pic]setFrame:CGRectMake(BORDER_THICKNESS, BORDER_THICKNESS, IMAGE_WIDTH-(2 * BORDER_THICKNESS), imageHeight == 0 ? imageHeight : imageHeight - BORDER_THICKNESS)];
    [[cell title]setFrame:CGRectMake(BOX_PADDING, imageHeight+GAP_BETWEEN_TEXTS, maxTitleWidth, titleSize.height)];
    [[cell description]setFrame:CGRectMake  (BOX_PADDING, imageHeight + (GAP_BETWEEN_TEXTS * 2) + titleSize.height, MAX_DESCRIPTION_WIDTH, descriptionSize.height)];
    [[cell priceLabel]setFrame:CGRectMake(BOX_WIDTH-priceSize.width - PRICE_PADDING - BORDER_THICKNESS, BORDER_THICKNESS, priceSize.width + PRICE_PADDING, PRICE_HEIGHT)];
    [[cell contactSeller]setFrame:CGRectMake(BOX_WIDTH - CONTACT_WIDTH - BORDER_THICKNESS - CORNER_RADIUS, containerHeight - CONTACT_HEIGHT - BORDER_THICKNESS - CORNER_RADIUS, CONTACT_WIDTH, CONTACT_HEIGHT)];
    [cell setItem:object];
    
    [cell sizeToFit];

    if ([indexPath row] >= [itemArray count] - 1) {
        [self addItemsToBottomFromIndex:[itemArray count]];
    }
    
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // do nothing
}

- (IBAction)revealCategories:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)revealNetworks:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    //    [[APP_DELEGATE viewController] presentModalViewController:controller animated:YES];
    [self dismissModalViewControllerAnimated:YES];
    
    if (result == MessageComposeResultCancelled)
        NSLog(@"Message cancelled");
    else if (result == MessageComposeResultSent)
        NSLog(@"Message sent");
    else
        NSLog(@"Message failed");
}


@end
