//
//  ProfileOfferDetail.h
//  Pamba
//
//  Created by Firststep Consulting on 7/30/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "Tabbar.h"
#import "Navi.h"
#import "Home.h"

@interface ProfileOfferDetail : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

{
    Singleton *sharedManager;
    Home *homePage;
    float previousScrollViewYOffset;
    float startScrollViewYOffset;
    NSMutableDictionary *listJSON;
    UIRefreshControl *refreshController;
}
@property (nonatomic) NSString *offerID;

@property (weak, nonatomic) IBOutlet UICollectionView *mycollectionView;
@property (weak, nonatomic) IBOutlet UILabel *noresultLabel;

@end
