//
//  Home.h
//  Samplink
//
//  Created by Firststep Consulting on 1/26/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import <CarbonKit/CarbonKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Home : UIViewController <UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>

{
    Singleton *sharedManager;
    BOOL filterShow;
    
    CLLocationManager * locationManager;
    Home *homePage;
    CarbonTabSwipeNavigation *carbon;
}

@property(weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property(weak, nonatomic) IBOutlet UIView *targetView;

@property (weak, nonatomic) IBOutlet UIImageView *rightAlert;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;

@property(weak, nonatomic) IBOutlet UIView *bgView;
@property(weak, nonatomic) IBOutlet UIView *headerView;

@property (retain, nonatomic) IBOutlet UITableView *myTable;

//- (IBAction)showLeftMenuPressed:(id)sender;
- (IBAction)showRightMenuPressed:(id)sender;
@end
