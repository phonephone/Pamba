//
//  Home.m
//  Samplink
//
//  Created by Firststep Consulting on 1/26/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "Home.h"
#import "RightMenu.h"
#import "MenuCell.h"
#import "OfferList.h"
#import "RequestList.h"

@interface Home () <CarbonTabSwipeNavigationDelegate> {
    NSArray *listCat;
    CarbonTabSwipeNavigation *carbonTabSwipeNavigation;
}

@end

@implementation Home

@synthesize toolBar,targetView,rightAlert,rightBtn,filterBtn,bgView,headerView,myTable;

- (void)viewWillLayoutSubviews
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
     self.menuContainerViewController.panMode = YES;
    
    if (sharedManager.loginStatus) {
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UIViewController *pageViewController = self.tabBarController;
    //NSLog(@"AAAAAAAAA %@\n%@\n%@\n%@\n%@\n%@",pageViewController.parentViewController,pageViewController.presentedViewController,pageViewController.presentingViewController,pageViewController.navigationController,pageViewController.tabBarController,pageViewController.childViewControllers);
    
    sharedManager = [Singleton sharedManager];
    
    sharedManager.mainTabbar = (Tabbar *)self.tabBarController;
    
    sharedManager.homeExisted = YES;
    
    rightAlert.hidden = YES;
    
    myTable.hidden = YES;
    
    bgView.backgroundColor = sharedManager.mainThemeColor;
    headerView.backgroundColor = sharedManager.mainThemeColor;
    
    [rightBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [filterBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    myTable.layer.masksToBounds = NO;
    // *** Set light gray color as shown in sample ***
    myTable.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    
    // *** *** Use following to add Shadow top, left ***
    //myTable.layer.shadowOffset = CGSizeMake(-5.0f, -5.0f);
    
    // *** Use following to add Shadow bottom, right ***
    //myTable.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    
    // *** Use following to add Shadow top, left, bottom, right ***
    //myTable.layer.shadowOffset = CGSizeZero;
    //myTable.layer.shadowRadius = 5.0f;
    
    myTable.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    myTable.layer.shadowRadius = 5.0f;
    
    // *** Set shadowOpacity to full (1) ***
    myTable.layer.shadowOpacity = 1.0f;
    
    //self.title = @"CarbonKit";

    listCat = @[
                   //[UIImage imageNamed:@"search"],
                   @"เสนอที่นั่งล่าสุด",
                   @"ต้องการที่นั่งล่าสุด",
                   ];
    
    carbonTabSwipeNavigation = [[CarbonTabSwipeNavigation alloc] initWithItems:listCat toolBar:toolBar delegate:self];
    
    [carbonTabSwipeNavigation insertIntoRootViewController:self andTargetView:self.targetView];
    
    [self style];
    
    RightMenu *rm = (RightMenu*)[sharedManager.mainRoot.childViewControllers objectAtIndex:0];
    [rm loadProfile];
    
    //long stackCount = [self.navigationController.viewControllers count];
    //NSLog(@"%ld + %@",stackCount,[self.navigationController.viewControllers objectAtIndex:num-1]);
}

- (void)viewDidAppear:(BOOL)animated {
    myTable.frame  = CGRectMake(myTable.frame.origin.x, headerView.frame.origin.y+headerView.frame.size.height - myTable.frame.size.height, myTable.frame.size.width, myTable.frame.size.height);
}

- (void)style {
    
    /*
    UIColor *color = [UIColor colorWithRed:243.0 / 255 green:75.0 / 255 blue:152.0 / 255 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = color;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    */
    
    //carbonTabSwipeNavigation.toolbar.backgroundColor = [UIColor redColor];
    carbonTabSwipeNavigation.toolbar.barTintColor = [UIColor whiteColor];
    carbonTabSwipeNavigation.toolbar.translucent = NO;
    [carbonTabSwipeNavigation setIndicatorColor:[UIColor colorWithRed:41.0/255 green:169.0/255 blue:225.0/255 alpha:1]];
    
    carbonTabSwipeNavigation.toolbarHeight = [NSLayoutConstraint constraintWithItem:toolBar
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                     multiplier:1.0
                                                       constant:45];
    
    [self.view addConstraint:carbonTabSwipeNavigation.toolbarHeight];
    
    [carbonTabSwipeNavigation setTabExtraWidth:0];
    
    int width = [UIScreen mainScreen].bounds.size.width/2;
    [carbonTabSwipeNavigation.carbonSegmentedControl setWidth:width forSegmentAtIndex:0];
    [carbonTabSwipeNavigation.carbonSegmentedControl setWidth:width forSegmentAtIndex:1];
    
    // Custimize segmented control
    [carbonTabSwipeNavigation setNormalColor:[UIColor colorWithRed:79.0/255 green:79.0/255 blue:79.0/255 alpha:1] font:[UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1]];
    [carbonTabSwipeNavigation setSelectedColor:[UIColor colorWithRed:41.0/255 green:169.0/255 blue:225.0/255 alpha:1] font:[UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1]];
    [carbonTabSwipeNavigation setCurrentTabIndex:0];
}

#pragma mark - CarbonTabSwipeNavigation Delegate
// required
- (nonnull UIViewController *)carbonTabSwipeNavigation:
(nonnull CarbonTabSwipeNavigation *)carbontTabSwipeNavigation
                                 viewControllerAtIndex:(NSUInteger)index {
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    sharedManager = [Singleton sharedManager];
    
    switch (index)
    {
            /*
             case 0:
             sharedManager.productList = @"Search";
             return [storyboard instantiateViewControllerWithIdentifier:@"Search"];
             */
            
        case 0:
            return [self.storyboard instantiateViewControllerWithIdentifier:@"OfferList"];
        case 1:
            return [self.storyboard instantiateViewControllerWithIdentifier:@"RequestList"];
            
        default:
            return [self.storyboard instantiateViewControllerWithIdentifier:@"OfferList"];
    }

}

// optional
- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                 willMoveAtIndex:(NSUInteger)index {
}

- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                  didMoveAtIndex:(NSUInteger)index {
    //NSLog(@"Did move at index: %ld", (unsigned long)index);
}

- (UIBarPosition)barPositionForCarbonTabSwipeNavigation:
(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation {
    return UIBarPositionTop; // default UIBarPositionTop
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return myTable.frame.size.height/2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuCell *cell = (MenuCell *)[tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    
    cell.menuLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1];
    
    if (indexPath.row == 0) {
        cell.menuLabel.text = @"วันที่ใกล้ที่สุด";
        
    }
    else if (indexPath.row == 1) {
        cell.menuLabel.text = @"พื้นที่ใกล้เคียง";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tabbar *tab = (Tabbar*)sharedManager.mainTabbar;
    Navi *navi = (Navi*)[tab.childViewControllers objectAtIndex:0];
    homePage = (Home*)[navi.childViewControllers objectAtIndex:0];
    carbon = [homePage.childViewControllers objectAtIndex:0];
    
    if (indexPath.row == 0)
    {
        sharedManager.sortMode = @"date";
        
        NSArray* keys = [carbon.viewControllers allKeys];
        //NSLog(@"keys %@",keys);
        for(int i = 0; i < [keys count]; i++)
        {
            if ([[carbon.viewControllers objectForKey:[keys objectAtIndex:i]] isKindOfClass:[OfferList class]]) {
                OfferList* ofl = (OfferList*)[carbon.viewControllers objectForKey:[keys objectAtIndex:i]];
                [ofl loadList];
            }
            if ([[carbon.viewControllers objectForKey:[keys objectAtIndex:i]] isKindOfClass:[RequestList class]]) {
                RequestList* rql = (RequestList*)[carbon.viewControllers objectForKey:[keys objectAtIndex:i]];
                [rql loadList];
            }
        }
    }
    else if (indexPath.row == 1)
    {
        sharedManager.sortMode = @"nearby";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Location Services ไม่ได้รับอนุญาต" message:@"คุณสามารถอนุญาติให้ Pamba Shareways เข้าถึง Location ของคุณได้ด้วยการปรับค่าที่ Settings > Privacy > Location Services" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                        }];
        [alertController addAction:settingAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Canelled");
        }];
        [alertController addAction:cancelAction];
        
        if(![CLLocationManager locationServicesEnabled]){
            //ปิด Location Service
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            //ปิด Location Service เฉพาะแอพ

             [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            //เปิด Location Service
            
            CLLocationCoordinate2D coordinate = [self getLocation];
            sharedManager.latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
            sharedManager.longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
            
            //sharedManager.latitude = @"13.8699978";
            //sharedManager.longitude = @"100.4672951";
            
            NSArray* keys = [carbon.viewControllers allKeys];
            //NSLog(@"keys %@",keys);
            for(int i = 0; i < [keys count]; i++)
            {
                if ([[carbon.viewControllers objectForKey:[keys objectAtIndex:i]] isKindOfClass:[OfferList class]]) {
                    OfferList* ofl = (OfferList*)[carbon.viewControllers objectForKey:[keys objectAtIndex:i]];
                    [ofl loadList];
                }
                if ([[carbon.viewControllers objectForKey:[keys objectAtIndex:i]] isKindOfClass:[RequestList class]]) {
                    RequestList* rql = (RequestList*)[carbon.viewControllers objectForKey:[keys objectAtIndex:i]];
                    [rql loadList];
                }
            }
        }
    }
    
    [self performSelector:@selector(filterClick:) withObject:nil afterDelay:0.0];
}

-(CLLocationCoordinate2D) getLocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    [locationManager stopUpdatingLocation];
    return coordinate;
}

- (IBAction)filterClick:(id)sender
{
    if (filterShow) { //Hide
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            myTable.frame  = CGRectMake(myTable.frame.origin.x, headerView.frame.origin.y+headerView.frame.size.height - myTable.frame.size.height, myTable.frame.size.width, myTable.frame.size.height);
        } completion:^(BOOL finished) {
            myTable.hidden = YES;
            filterShow = NO;
        }];
    }
    else //Show
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            myTable.frame  = CGRectMake(myTable.frame.origin.x, headerView.frame.origin.y+headerView.frame.size.height, myTable.frame.size.width, myTable.frame.size.height);
            myTable.hidden = NO;
        } completion:^(BOOL finished) {
            
            filterShow = YES;
        }];
    }
    
}

- (IBAction)showLeftMenuPressed:(id)sender {
    
}

- (IBAction)showRightMenuPressed:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

- (void)alertTitle:(NSString*)title detail:(NSString*)alertDetail
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:alertDetail preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
