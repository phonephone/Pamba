//
//  EditTrip.m
//  Pamba
//
//  Created by Firststep Consulting on 21/7/18.
//  Copyright © 2018 TMA Digital. All rights reserved.
//

#import "EditTrip.h"

@interface EditTrip ()

@end

@implementation EditTrip
{
    NSArray *seatArray;
}

@synthesize bgView,headerView,headerTitle,nextBtn,dateLabel,timeLabel,priceLabel,seatLabel,dateField,timeField,priceField,seatField,offerID,goDate,goH,goM,seats,price,remark,remarkTitle,remarkText,orangeBtn,backBtn;

- (void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = NO;
    self.tabBarController.tabBar.hidden = YES;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"EditOffer"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewWillLayoutSubviews
{
    
}

- (void)viewDidLayoutSubviews
{
    if (!firstRender) {
        firstRender = YES;
    }
    else{
         [self addbottomBorder:dateField withColor:nil];
         [self addbottomBorder:timeField withColor:nil];
         [self addbottomBorder:priceField withColor:nil];
         [self addbottomBorder:seatField withColor:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    seatArray = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    
    sharedManager = [Singleton sharedManager];
    
    //[[UINavigationBar appearance] setBarTintColor:sharedManager.mainThemeColor];
    
    Tabbar *tab = (Tabbar*)sharedManager.mainTabbar;
    Navi *navi = (Navi*)[tab.childViewControllers objectAtIndex:0];
    homePage = (Home*)[navi.childViewControllers objectAtIndex:0];
    
    //NSLog(@"What %@",[tab.childViewControllers objectAtIndex:0]);
    
    [headerTitle setAttributedText:[self shorttext:headerTitle.text withFont:[UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+4]]];
    
    remarkTitle.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+3];
    [self shorttext:remarkTitle];
    
    remarkText.delegate = self;
    remarkText.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2];
    remarkText.layer.borderWidth = 1.0f;
    remarkText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [orangeBtn.titleLabel setFont:[UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+6]];
    
    [self clearValue];
}

-(void)clearValue
{
    [dateLabel setAttributedText:[self shorttext:dateLabel.text withFont:nil]];
    [timeLabel setAttributedText:[self shorttext:timeLabel.text withFont:nil]];
    
    NSString *detect = @"ค่าโดยสาร";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:priceLabel.text];
    [attrString setAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Kanit-LightItalic" size:sharedManager.fontSize+2] } range:NSMakeRange(0, priceLabel.text.length)];
    [attrString setAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2] } range:NSMakeRange(0, detect.length)];
    [attrString addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:-0.5] range:NSMakeRange(0, priceLabel.text.length)];
    [priceLabel setAttributedText:attrString];
    
    [seatLabel setAttributedText:[self shorttext:seatLabel.text withFont:nil]];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"th"];
    df = [[NSDateFormatter alloc] init];
    //df.dateStyle = NSDateFormatterShortStyle;
    [df setLocale:locale];
    
    dayPicker = [[UIDatePicker alloc]init];
    [dayPicker setDatePickerMode:UIDatePickerModeDate];
    [dayPicker setMinimumDate: [NSDate date]];
    [dayPicker setLocale:locale];
    dayPicker.calendar = [locale objectForKey:NSLocaleCalendar];
    dayPicker.tag = 1;
    [dayPicker addTarget:self action:@selector(datePickerValueChanged:)forControlEvents:UIControlEventValueChanged];
    
    timePicker = [[UIDatePicker alloc]init];
    [timePicker setDatePickerMode:UIDatePickerModeTime];
    [timePicker setLocale:locale];
    timePicker.tag = 2;
    [timePicker addTarget:self action:@selector(datePickerValueChanged:)forControlEvents:UIControlEventValueChanged];
    
    seatPicker = [[UIPickerView alloc]init];
    seatPicker.delegate = self;
    seatPicker.dataSource = self;
    [seatPicker setShowsSelectionIndicator:YES];
    seatPicker.tag = 5;
    [seatPicker selectRow:2 inComponent:0 animated:YES];
    
    dateField.inputView = dayPicker;
    [df setDateFormat:@"dd MMM yyyy"];
    NSDate *editDate = [df dateFromString:goDate];
    dateField.text = [df stringFromDate:editDate];
    [dayPicker setDate:[df dateFromString:goDate]];
    
    timeField.inputView = timePicker;
    [df setDateFormat:@"HH : mm"];
    NSString *time = [NSString stringWithFormat:@"%@ : %@",goH,goM];
    timeField.text = time;
    [timePicker setDate:[df dateFromString:time]];
    
    seatField.inputView = seatPicker;
    
    //price = @"0";
    priceField.text = price;
    if ([priceField.text intValue] == 0) {
        priceField.text = @"ฟรี";
    }
    else{
        priceField.text = [NSString stringWithFormat:@"%d บาท",[price intValue]];
    }
    
    //seats = @"3";
    seatField.text = seats;
    for (int i=0; i<[seatArray count]; i++)
    {
        if ([seats intValue] == i) {
            [seatPicker selectRow:i inComponent:0 animated:YES];
        }
    }
    
    remarkText.text = remark;
    if ([remarkText.text isEqualToString:@""]) {
        remarkText.text = @"ใส่รายละเอียด...";
    }
    
    /*
    [df setDateFormat:@"yyyy-MM-dd"];
    goDate = [df stringFromDate:[NSDate date]];
     */
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"Start");
    if (textField.tag == 99) {
        if ([textField.text isEqualToString:@"ฟรี"]) {
            priceField.text = @"0";
        }
        else{
            priceField.text = [textField.text stringByReplacingOccurrencesOfString:@" บาท" withString:@""];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"End");
    
    if (textField.tag == 99) {
        if ([textField.text intValue] == 0) {
            price = @"0";
            priceField.text = @"ฟรี";
        }
        else{
            price = textField.text;
            priceField.text = [NSString stringWithFormat:@"%d บาท",[textField.text intValue]];
        }
    }
}

- (void)datePickerValueChanged:(UIDatePicker *)datePicker
{
    switch (datePicker.tag) {
        case 1://Date
            [df setDateFormat:@"dd MMM yyyy"];
            dateField.text = [df stringFromDate:datePicker.date];
            
            [df setDateFormat:@"yyyy-MM-dd"];
            goDate = [df stringFromDate:datePicker.date];
            break;
            
        case 2://Time
            [df setDateFormat:@"HH : mm"];
            timeField.text = [df stringFromDate:datePicker.date];
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:datePicker.date];
            goH = [NSString stringWithFormat:@"%ld",(long)[components hour]];
            goM = [NSString stringWithFormat:@"%ld",(long)[components minute]];
            break;
    }
}

- (long)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (long)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    long rowNum = 0;
    
    switch (pickerView.tag) {
            
        case 5://Seat
            rowNum = [seatArray count];
            break;
            
        default:
            break;
    }
    
    return rowNum;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *rowTitle;
    
    switch (pickerView.tag) {
            
        case 5://Seat
            rowTitle = [seatArray objectAtIndex:row];
            break;
            
        default:
            break;
    }
    
    return rowTitle;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (pickerView.tag) {
            
        case 5://Seat
            seatField.text = [seatArray objectAtIndex:row];
            seats = [seatArray objectAtIndex:row];
            break;
            
        default:
            break;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"ใส่รายละเอียด..."]) {
        textView.text = @"";
        //textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"ใส่รายละเอียด...";
        //textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (UITextField*)addbottomBorder:(UITextField*)textField withColor:(UIColor*)color
{
    textField.delegate = self;
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, textField.frame.size.height - 1, textField.frame.size.width, 1.0f);
    
    if (color == nil) {
        bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1].CGColor;
    }
    
    [textField.layer addSublayer:bottomBorder];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    textField.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2];
    
    return textField;
}


- (IBAction)orangeClick:(id)sender
{
    sharedManager.reloadOffer = YES;
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
    NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
    //df.dateStyle = NSDateFormatterShortStyle;
    [df2 setLocale:locale];
    [df2 setDateFormat:@"yyyy-MM-dd"];
    goDate = [df2 stringFromDate:dayPicker.date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:timePicker.date];
    goH = [NSString stringWithFormat:@"%ld",(long)[components hour]];
    goM = [NSString stringWithFormat:@"%ld",(long)[components minute]];
    
    if ([remarkText.text isEqualToString:@"ใส่รายละเอียด..."]) {
        remark = @"";
    }
    else
    {
        remark = remarkText.text;
    }
    NSLog(@"%@\n%@\n%@:%@\n%@\n%@\n%@",offerID,goDate,goH,goM,seats,price,remark);
    
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    NSLog(@"offid %@",offerID);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@updateOffer",HOST_DOMAIN];
    NSDictionary *parameters = @{@"oid":offerID,
                                 @"goDate":goDate,
                                 @"goH":goH,
                                 @"goM":goM,
                                 @"seats":seats,
                                 @"price":price,
                                 @"remark":remark};
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //NSLog(@"listJSON %@",responseObject);
         //listJSON = [[responseObject objectForKey:@"data"] mutableCopy];
         
         HUD.textLabel.text = @"การแก้ไขถูกบันทึกแล้ว";
         HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
         [HUD dismissAfterDelay:3.0 animated:YES];
         [self.navigationController popViewControllerAnimated:YES];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [HUD dismissAnimated:YES];
         [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
     }];
}

- (NSAttributedString *)shorttext:(NSString *)originalText withFont:(UIFont*)fontName
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:originalText];
    [text addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:-0.5] range:NSMakeRange(0, text.length)];
    
    if (fontName == nil) {
        [text setAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2] } range:NSMakeRange(0, text.length)];
    }
    else{
        [text setAttributes:@{ NSFontAttributeName:fontName } range:NSMakeRange(0, text.length)];
    }
    
    return text;
}

- (UILabel *)shorttext:(UILabel *)originalLabel
{
    if (originalLabel.text) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:originalLabel.text];
        [text addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:-0.5] range:NSMakeRange(0, text.length)];
        [originalLabel setAttributedText:text];
    }
    return originalLabel;
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertTitle:(NSString*)title detail:(NSString*)alertDetail
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:alertDetail preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
