//
//  RequestDetail.h
//  Pamba
//
//  Created by Firststep Consulting on 7/11/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "Tabbar.h"
#import "Navi.h"
#import "Home.h"

@interface RequestDetail : UIViewController <UITableViewDelegate,UITableViewDataSource>

{
    Singleton *sharedManager;
    Home *homePage;
    NSMutableArray *listJSON;
    BOOL owner;
}

@property (nonatomic) NSString *requestID;

@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property(weak, nonatomic) IBOutlet UIView *bgView;
@property(weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;

@property (retain, nonatomic) IBOutlet UITableView *myTable;

@property (weak, nonatomic) IBOutlet UIButton *blueBtn;
@property (weak, nonatomic) IBOutlet UIButton *orangeBtn;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@end

