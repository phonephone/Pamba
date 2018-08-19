//
//  ProfileOffer.h
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

@interface ProfileOffer : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate>
{
    Singleton *sharedManager;
    Home *homePage;
    float previousScrollViewYOffset;
    float startScrollViewYOffset;
    NSMutableArray *listJSON;
    UIRefreshControl *refreshController;
    
    UIDatePicker *dayPicker;
    NSDateFormatter *df;
    UITextField *dateField;
    NSString *goDate;
    NSString *goDateEN;
    NSString *goH;
    NSString *goM;
    
    NSLocale *localeTH;
    NSLocale *localeEN;
    
    NSString *selectID;
}
@property (nonatomic) NSString *mode;

@property(weak, nonatomic) IBOutlet UIView *bgView;
@property(weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;

@property (weak, nonatomic) IBOutlet UICollectionView *mycollectionView;
@property (weak, nonatomic) IBOutlet UILabel *noresultLabel;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@end
