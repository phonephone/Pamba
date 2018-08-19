//
//  OfferMap.h
//  Pamba
//
//  Created by Firststep Consulting on 7/13/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"

@interface OfferMap : UIViewController <UIWebViewDelegate>
{
    Singleton *sharedManager;
    NSURLRequest *requestURL;
    JGProgressHUD *HUD;
}
@property (nonatomic) NSString *offerID;

@property(weak, nonatomic) IBOutlet UIView *bgView;
@property(weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;
    
@property (weak, nonatomic) IBOutlet UIWebView *myWebview;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@end
