//
//  PriceInfo.h
//  Pamba
//
//  Created by Firststep Consulting on 7/13/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"

@interface PriceInfo : UIViewController

{
    Singleton *sharedManager;
}

@property (nonatomic) NSString *distanceInfo;
@property (nonatomic) NSString *publicPrice;
@property (nonatomic) NSString *meterPrice;
    
@property (weak, nonatomic) IBOutlet UILabel *titleInfo;
@property (weak, nonatomic) IBOutlet UILabel *detailInfo;
@end
