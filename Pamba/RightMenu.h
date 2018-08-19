//
//  RightMenu.h
//  Samplink
//
//  Created by Firststep Consulting on 6/13/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "Tabbar.h"
#import "Navi.h"
#import "Home.h"

@interface RightMenu : UIViewController <UITableViewDelegate,UITableViewDataSource>

{
    Singleton *sharedManager;
    NSMutableIndexSet *expandedSections;
    Home *homePage;
    CarbonTabSwipeNavigation *carbon;
    
    int alertOffer;
    int alertReserve;
    int alertChat;
}

@property (retain, nonatomic) IBOutlet UITableView *myTable;

@property (weak, nonatomic) IBOutlet UIImageView *userPic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userSince;

- (void)loadProfile;

@end
