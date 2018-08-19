//
//  OfferList.h
//  Pamba
//
//  Created by Firststep Consulting on 7/7/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "Tabbar.h"
#import "Navi.h"
#import "Home.h"
#import <CoreLocation/CoreLocation.h>

@interface OfferList : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,CLLocationManagerDelegate>

{
    Singleton *sharedManager;
    Home *homePage;
    float previousScrollViewYOffset;
    float startScrollViewYOffset;
    NSMutableArray *listJSON;
    UIRefreshControl *refreshController;
    CLLocationManager * locationManager;
}

@property (weak, nonatomic) IBOutlet UICollectionView *mycollectionView;

- (void)loadList;
@end
