//
//  Login.h
//  Pamba
//
//  Created by Firststep Consulting on 7/31/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import <CoreLocation/CoreLocation.h>

@interface Login : UIViewController <CLLocationManagerDelegate>
{
    Singleton *sharedManager;
    NSMutableDictionary *loginJSON;
    CLLocationManager * locationManager;
    BOOL waitOTP;
}
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *otpLabel;
@property (weak, nonatomic) IBOutlet UITextField *mobileField;
@property (weak, nonatomic) IBOutlet UITextField *otpField;
@property (weak, nonatomic) IBOutlet UIButton *requestOTPBtn;
@property (weak, nonatomic) IBOutlet UIButton *submitOTPBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelOTPBtn;

@end
