//
//  ViewController.m
//  MarketLoco
//
//  Created by Jesse Daugherty on 3/15/13.
//  Copyright (c) 2013 Jesse Daugherty. All rights reserved.
//

#import "ViewController.h"

//TableView Cell Layout constants
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
#define CONTACT_WIDTH 140
#define LOADING_ROW_HEIGHT 80


@interface ViewController ()

@end

@implementation ViewController

@synthesize tbView,filteredItemArray,itemArray,locationManager,userLocation, itemPics, endResultsText,
network, cellForReference, category, networkButton, categoryButton, locoBar, networkName;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [APP_DELEGATE setViewController:self];
    endResults = false;
    endResultsText = @"Loading...";
    [ParseData sharedParseData];
    [self initMixpanel];
    [self getReferenceFancyCell];
    [self makeBarPretty];
    [self setInitialNetwork];
    [self initContactPressedCount];
    [self setupSlidingControl];
    self.tbView.delegate = self;
    self.tbView.dataSource = self;
}


//-------------------------------------- QUERIES & RELATED CODE ----------------------------------------------

-(void)geoQueryForNetwork {
    PFQuery *query = [PFQuery queryWithClassName:@"Networks"];
    // Interested in locations near user.
    PFGeoPoint *myGeoPoint = [PFGeoPoint geoPointWithLatitude:userLocation.coordinate.latitude
                                                    longitude:userLocation.coordinate.longitude];
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
    currentlyLoadingMore = true;
    [self pullNewestItemsForNetwork:locNetwork andCategory:@"All Items"];
}

-(PFQuery *)createQuery {
    PFQuery *globalQuery = [PFQuery queryWithClassName:@"Listings"];
    [globalQuery whereKeyDoesNotExist:@"network"];
    
    PFQuery *localQuery = [PFQuery queryWithClassName:@"Listings"];
    [localQuery whereKey:@"network" equalTo:network];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects: globalQuery, localQuery, nil]];
    [query orderByDescending:@"premiumListing"];
    [query addDescendingOrder:@"createdAt"];
    if (![category isEqualToString:@"All Items"]) {
        [query whereKey:@"category" equalTo:category];
    }
    [query setLimit:20];
    return query;
}

-(void)pullNewestItemsForNetwork:(NSString *) newNetwork andCategory:(NSString *) newCategory {

    if (!network || !category || !([network isEqualToString:newNetwork] && [category isEqualToString:newCategory])) {
        network = newNetwork;
        category = newCategory;
        networkName = [[NSUserDefaults standardUserDefaults] objectForKey:@"networkName"];
        [[self networkButton] setTitle:networkName];
        [[self categoryButton] setTitle:category];
        endResults = false;
        PFQuery *query = [self createQuery];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            currentlyLoadingMore = false;
            if (!error) {
                // The find succeeded.
                
                NSLog(@"Successfully retrieved the first %d listings.", objects.count);
                itemArray = objects;
                if ([objects count] == 0) {
                    endResultsText = @"No Results";
                    endResults = true;
                } else {
                    endResultsText = @"Loading more...";
                }
                [tbView reloadData];
                itemPics = [NSMutableArray arrayWithCapacity:[itemArray count]];
                for(int i = 0; i < [itemArray count]; i++) [itemPics addObject: [NSNull null]];
                for (int i = 0; i < [itemArray count]; i++) {
                    dispatch_async(dispatch_get_global_queue(0,0), ^{
                        if ([[itemArray objectAtIndex:i] objectForKey:@"uploadedImage"] == [NSNumber numberWithBool:YES]) {
                            NSData * data = [[NSData alloc]
                                             initWithContentsOfURL:
                                             [NSURL URLWithString:
                                              [[itemArray objectAtIndex:i]
                                               objectForKey:@"picUrl"]]];
                            
                            if ( data != nil ) {
                                if (i < [itemPics count]) {
                                    [itemPics replaceObjectAtIndex:i withObject:data];
                                    if (i <= 3) {
                                        [self.tbView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                    }
                                }
                            }
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
    PFQuery *query = [self createQuery];
    query.skip = startIndex;
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number > startIndex) {
            [self getMoreObjectsWithQuery:query andStartIndex:startIndex];
        }
        else {
            if ([itemArray count] > 0) {
                endResultsText = @"End of Results";
                endResults = true;
            }
            else {
                endResultsText = @"No Results";
                endResults = true;
            }
            [tbView reloadData];
        }
    }];
}


-(void)getMoreObjectsWithQuery:(PFQuery *)query andStartIndex:(int) startIndex {
    endResults = false;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        currentlyLoadingMore = false;
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
                        
                        NSData * data = [[NSData alloc]
                                         initWithContentsOfURL:
                                         [NSURL URLWithString:
                                          [[itemArray objectAtIndex:realIndex]
                                           objectForKey:@"picUrl"]]];
                        
                        if ( data != nil ) {
                            if (i < [itemPics count]) {
                                [itemPics replaceObjectAtIndex:realIndex withObject:data];
                            }
                        }
                    }
                });
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}



//----------------------------- TABLE VIEW DELEGATE & DATA SOURCE METHODS -------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [itemArray count] + 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] < [itemArray count]) {
        return [self heightForFancyCellAtRow:[indexPath row]];
    }
    return LOADING_ROW_HEIGHT;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= [itemArray count]) {
        if (!(currentlyLoadingMore || endResults || [indexPath row] == 0)) {
            currentlyLoadingMore = true;
            [self addItemsToBottomFromIndex:[itemArray count]];
        }
        return [self endOfResultsCell];
    }
    else {
        return [self fancyCellAtRow:[indexPath row]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // do nothing
}




//----------------------------------- TABLE VIEW CELL HELPER METHODS ------------------------------------------

-(CGFloat)heightForFancyCellAtRow:(NSInteger)row {
    PFObject *object = [itemArray objectAtIndex:row];
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
    CGSize descriptionSize = [descrip sizeWithFont:daFont
                              constrainedToSize:CGSizeMake(MAX_DESCRIPTION_WIDTH, MAX_DESCRIPTION_HEIGHT)
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
    return imageHeight + titleSize.height + descriptionSize.height +
    GAP_BETWEEN_CELLS + (2 * GAP_BETWEEN_TEXTS) + BOX_PADDING + CONTACT_HEIGHT;
}

-(UITableViewCell *)fancyCellAtRow:(NSInteger)row {
    static NSString *CellIdentifier = @"fancyCell";
    FancyCell *cell = (FancyCell *) [tbView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
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
    PFObject *object = [itemArray objectAtIndex:row];
    NSData * imgData = [itemPics objectAtIndex:row];
    int imageHeight = 0;
    NSNumber *imgExists = [object objectForKey:@"uploadedImage"];
    if (imgExists == [NSNumber numberWithBool:YES]) {
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
    int containerHeight = imageHeight + descriptionSize.height + titleSize.height +
    (GAP_BETWEEN_TEXTS * 2) + BOX_PADDING + CONTACT_HEIGHT;
    [[cell container] setFrame:CGRectMake((320-(BOX_WIDTH))/2,
                                          GAP_BETWEEN_CELLS,
                                          BOX_WIDTH,
                                          containerHeight)];
    [cell container].layer.cornerRadius = CORNER_RADIUS;
    [cell container].layer.borderWidth = BORDER_THICKNESS;
    [cell container].layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.4 alpha:.25].CGColor;
    [cell container].layer.masksToBounds = YES;
    [[cell pic]setFrame:CGRectMake(BORDER_THICKNESS,
                                   BORDER_THICKNESS,
                                   IMAGE_WIDTH-(2 * BORDER_THICKNESS),
                                   imageHeight == 0 ? imageHeight : imageHeight - BORDER_THICKNESS)];
    [[cell title]setFrame:CGRectMake(BOX_PADDING,
                                     imageHeight+GAP_BETWEEN_TEXTS,
                                     maxTitleWidth,
                                     titleSize.height)];
    [[cell description]setFrame:CGRectMake  (BOX_PADDING,
                                             imageHeight + (GAP_BETWEEN_TEXTS * 2) + titleSize.height,
                                             MAX_DESCRIPTION_WIDTH,
                                             descriptionSize.height)];
    [[cell priceLabel]setFrame:CGRectMake(BOX_WIDTH-priceSize.width - PRICE_PADDING - BORDER_THICKNESS,
                                          BORDER_THICKNESS,
                                          priceSize.width + PRICE_PADDING,
                                          PRICE_HEIGHT)];
    [[cell contactSeller]setFrame:CGRectMake(BOX_WIDTH - CONTACT_WIDTH - BORDER_THICKNESS - CORNER_RADIUS,
                                             containerHeight - CONTACT_HEIGHT - BORDER_THICKNESS - CORNER_RADIUS,
                                             CONTACT_WIDTH,
                                             CONTACT_HEIGHT)];
    
    [cell setItem:object];
    NSNumber *call = [[object fetchIfNeeded] objectForKey:@"call"];
    if (call && call == [NSNumber numberWithBool:YES]) {
        [cell setCallNotText:[NSNumber numberWithBool:YES]];
        [[cell contactSeller]setTitle:@"Call Seller" forState:UIControlStateNormal];
    } else {
        [cell setCallNotText:[NSNumber numberWithBool:NO]];
        [[cell contactSeller]setTitle:@"Text Seller" forState:UIControlStateNormal];
    }
    [cell sizeToFit];
    return cell;
}

-(UITableViewCell *)endOfResultsCell {
    NSString *CellIdentifier = @"endResultsCell";
    UITableViewCell *cell = [tbView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, 320, LOADING_ROW_HEIGHT)];
    }
    UILabel *status = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 280, 40)];
    [status setTextAlignment:NSTextAlignmentCenter];
    [status setText:endResultsText];
    [cell addSubview:status];
    return cell;
}



//------------------------------------ VIEW DID LOAD HELPERS -----------------------------------------

-(void)initContactPressedCount {
    NSInteger num = [[NSUserDefaults standardUserDefaults] integerForKey:@"contactPressed"];
    if (!num) {
        num = 0;
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"contactPressed"];
    }
    contactPressed = num;
}

-(void) makeBarPretty {
    UIView *locoBarView = [[UIView alloc] initWithFrame:CGRectMake(80, 10, 70, 20)];
    UIImageView *locoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locologo.png"]];
    [locoBarView addSubview:locoView];
    [locoBar setTitleView:locoBarView];
}

-(void)getReferenceFancyCell {
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
}

-(void)initMixpanel {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Opened iOS App"];
}

-(void)setupSlidingControl {
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    if (![self.slidingViewController.underRightViewController isKindOfClass:[NetworksViewController class]]) {
        self.slidingViewController.underRightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Networks"];
    }
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[CategoriesViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Categories"];
    }
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

-(void)setInitialNetwork {
    networkName = [[NSUserDefaults standardUserDefaults]objectForKey:@"networkName"];
    NSString *prevNetwork = [[NSUserDefaults standardUserDefaults]objectForKey:@"network"];
    if (!prevNetwork) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager startUpdatingLocation];
        locationManager.delegate = self;
    } else {
        currentlyLoadingMore = true;
        [self pullNewestItemsForNetwork:prevNetwork andCategory:@"All Items" ];
    }
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



//------------------------------------ GROWTHHH HACKSSS -----------------------------------------

#define TAG_FB 1
#define TAG_INVITE 2
#define TAG_RATE 3
#define FB_LIKE_TITLE @"We like you!"
#define FB_LIKE_MESSAGE @"Do you like us? Check out our Facebook page."
#define INVITE_TITLE @"Invite your friends!"
#define INVITE_MESSAGE @"Help spread Loco across your campus"
#define INVITE_SMS_BODY @"Check out Loco on the app store. Its the best way to buy and sell stuff on campus!"
#define RATE_TITLE @"Enjoying the app?"
#define RATE_MESSAGE @"Take a minute to rate it on the app store. It means a lot to us!"
#define YES_TEXT @"Sure!"
#define LATER_TEXT @"Maybe Later"

-(void) growthHacksAfterClick {
    int contacts = contactPressed;
    bool dontWantToLike, dontWantToRate, dontWantToInvite;
    dontWantToLike = [[NSUserDefaults standardUserDefaults] boolForKey:@"dontWantToLike"];
    dontWantToRate = [[NSUserDefaults standardUserDefaults] boolForKey:@"dontWantToRate"];
    dontWantToInvite = [[NSUserDefaults standardUserDefaults] boolForKey:@"dontWantToInvite"];
    if (contacts == 1) {
        [self askToLikeUsOnFB];
    } else if (contacts == 3) {
        [self askToInviteFriends];
    } else if (contacts == 5) {
        [self askToRateUs];
    } else if (contacts > 1 && (contacts % 6 == 1) && !dontWantToLike) {
        [self askToLikeUsOnFB];
    } else if (contacts > 3 && (contacts % 6 == 3) && !dontWantToInvite) {
        [self askToInviteFriends];
    } else if (contacts > 5 && (contacts % 6 == 5) && !dontWantToRate) {
        [self askToRateUs];
    }
}


-(void) askToLikeUsOnFB {
    UIAlertView *alert = [[UIAlertView alloc]
                          
                          initWithTitle:FB_LIKE_TITLE
                          message:FB_LIKE_MESSAGE
                          delegate:self
                          cancelButtonTitle:LATER_TEXT
                          otherButtonTitles:YES_TEXT, nil];
    alert.tag = TAG_FB;
    [alert show];    
}

-(void) askToInviteFriends {
    UIAlertView *alert = [[UIAlertView alloc]
                          
                          initWithTitle:INVITE_TITLE
                          message:INVITE_MESSAGE 
                          delegate:self
                          cancelButtonTitle:LATER_TEXT
                          otherButtonTitles:YES_TEXT, nil];
    alert.tag = TAG_INVITE;
    [alert show];
}

-(void) askToRateUs {
    UIAlertView *alert = [[UIAlertView alloc]
                          
                          initWithTitle:RATE_TITLE
                          message:RATE_MESSAGE
                          delegate:self
                          cancelButtonTitle:LATER_TEXT
                          otherButtonTitles:YES_TEXT, nil];
    alert.tag = TAG_RATE;
    [alert show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_FB) {
        if (buttonIndex == 0) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dontWantToLike"];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dontWantToLike"];
            [self openFBPage];
        }
    } else if (alertView.tag == TAG_INVITE) {
        if (buttonIndex == 0) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dontWantToInvite"];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dontWantToInvite"];
            [self inviteFriendsPopup];
        }
    }
    else if (alertView.tag == TAG_RATE) {
        if (buttonIndex == 0) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dontWantToRate"];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dontWantToRate"];
            [self doRateApp];
        }
    }
}


-(void)openFBPage {
    NSURL *url = [NSURL URLWithString:@"fb://profile/100440650134797"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        //if facebook app is installed
        [[UIApplication sharedApplication] openURL:url];
    } else {
        //open in safari
        NSURL *link = [NSURL URLWithString:@"https://www.facebook.com/marketloco"];
        [[UIApplication sharedApplication] openURL:link];
    }
}

-(void)inviteFriendsPopup {
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    
    if (messageClass != nil) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = INVITE_SMS_BODY;
            controller.messageComposeDelegate = self;
            [self presentModalViewController:controller animated:YES];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Sorry!"
                              message: @"You cannot send messages from this device."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }

}

-(void)doRateApp {
    NSString* url = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=624395151";
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}



//------------------------------------ OTHER MISC METHODS -----------------------------------------


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
    else if (result == MessageComposeResultSent) {
        contactPressed++;
        [[NSUserDefaults standardUserDefaults] setInteger:contactPressed forKey:@"contactPressed"];
        [self growthHacksAfterClick];
        NSLog(@"Message sent");
    }
    else
        NSLog(@"Message failed");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
