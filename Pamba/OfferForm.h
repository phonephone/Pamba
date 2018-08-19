//
//  OfferForm.h
//  Pamba
//
//  Created by Firststep Consulting on 7/12/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "Tabbar.h"
#import "Navi.h"
#import "Home.h"
#import <CoreLocation/CoreLocation.h>
@import GooglePlaces;

@interface OfferForm : UIViewController <CLLocationManagerDelegate,UITextFieldDelegate,UITextViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

{
    Singleton *sharedManager;
    Home *homePage;
    NSMutableArray *listJSON;
    CLLocationManager * locationManager;
    
    UIDatePicker *dayPicker;
    UIDatePicker *timePicker;
    UIPickerView *extimePicker;
    UIPickerView *seatPicker;
    UIPickerView *bagPicker;
    NSDateFormatter *df;
    
    long nowEdit;
    NSString *fromID;
    NSString *toID;
    NSString *waypointID;
    NSString *distanceInfo;
    NSString *publicPrice;
    NSString *meterPrice;
    
    NSString *goDate;
    NSString *goH;
    NSString *goM;
    NSString *exTime;
    NSString *seats;
    NSString *luggage;
    
    NSString *price;
}
@property (nonatomic) NSString *carType;

@property(weak, nonatomic) IBOutlet UIView *bgView;
@property(weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;

@property (weak, nonatomic) IBOutlet UITextField *fromField;
@property (weak, nonatomic) IBOutlet UITextField *toField;

@property (weak, nonatomic) IBOutlet UIButton *targetBtn;
@property (weak, nonatomic) IBOutlet UIButton *swapBtn;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *extimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatLabel;
@property (weak, nonatomic) IBOutlet UILabel *bagLabel;

@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UITextField *priceField;
@property (weak, nonatomic) IBOutlet UITextField *extimeField;
@property (weak, nonatomic) IBOutlet UITextField *seatField;
@property (weak, nonatomic) IBOutlet UITextField *bagField;

@property (weak, nonatomic) IBOutlet UIButton *carBtn1;
@property (weak, nonatomic) IBOutlet UIButton *carBtn2;
@property (weak, nonatomic) IBOutlet UIButton *carBtn3;
@end
