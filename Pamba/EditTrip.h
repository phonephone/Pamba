//
//  EditTrip.h
//  Pamba
//
//  Created by Firststep Consulting on 21/7/18.
//  Copyright © 2018 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "Tabbar.h"
#import "Navi.h"
#import "Home.h"

@interface EditTrip : UIViewController <UITextFieldDelegate,UITextViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

{
    Singleton *sharedManager;
    Home *homePage;
    NSMutableArray *listJSON;
    
    UIDatePicker *dayPicker;
    UIDatePicker *timePicker;
    UIPickerView *seatPicker;
    NSDateFormatter *df;
    
    BOOL firstRender;
}
@property (nonatomic) NSString *offerID;
@property (nonatomic) NSString *goDate;
@property (nonatomic) NSString *goH;
@property (nonatomic) NSString *goM;
@property (nonatomic) NSString *seats;
@property (nonatomic) NSString *price;
@property (nonatomic) NSString *remark;

@property(weak, nonatomic) IBOutlet UIView *bgView;
@property(weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;

@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatLabel;

@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UITextField *priceField;
@property (weak, nonatomic) IBOutlet UITextField *seatField;

@property (weak, nonatomic) IBOutlet UILabel *remarkTitle;
@property (weak, nonatomic) IBOutlet UITextView *remarkText;

@property (weak, nonatomic) IBOutlet UIButton *orangeBtn;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end
