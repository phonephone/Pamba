//
//  ChatList.h
//  Pamba
//
//  Created by Firststep Consulting on 8/25/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"

@interface ChatList : UIViewController <UITableViewDelegate,UITableViewDataSource>

{
    Singleton *sharedManager;
    NSMutableArray *listJSON;
}

@property(weak, nonatomic) IBOutlet UIView *bgView;
@property(weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;

@property (retain, nonatomic) IBOutlet UITableView *myTable;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end
