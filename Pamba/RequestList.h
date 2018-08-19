//
//  RequestList.h
//  Pamba
//
//  Created by Firststep Consulting on 7/8/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "Tabbar.h"
#import "Navi.h"
#import "Home.h"

@interface RequestList : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

{
    Singleton *sharedManager;
    Home *homePage;
    float previousScrollViewYOffset;
    float startScrollViewYOffset;
    NSMutableArray *listJSON;
    
    UIRefreshControl *refreshController;
}

@property (weak, nonatomic) IBOutlet UICollectionView *mycollectionView;

- (void)loadList;
@end
