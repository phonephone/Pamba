//
//  RequestForm.m
//  Pamba
//
//  Created by Firststep Consulting on 7/14/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "RequestForm.h"
#import <GooglePlaces/GooglePlaces.h>
#import <CCMPopup/CCMPopupSegue.h>
#import "ProfileOffer.h"

@interface RequestForm () <GMSAutocompleteViewControllerDelegate>

@end

@implementation RequestForm
{
    GMSPlacesClient *_placesClient;
    GMSAutocompleteResultsViewController *_resultsViewController;
}

@synthesize bgView,headerView,headerTitle,fromField,toField,targetBtn,swapBtn,nextBtn,dateLabel,timeLabel,dateField,timeField,remarkTitle,remarkText;

- (void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = NO;
    self.tabBarController.tabBar.hidden = NO;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"RequestForm"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    if (sharedManager.clearRequest == YES) {
        [self clearValue];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sharedManager = [Singleton sharedManager];
    
    //[[UINavigationBar appearance] setBarTintColor:sharedManager.mainThemeColor];
    
    _placesClient = [GMSPlacesClient sharedClient];
    
    Tabbar *tab = (Tabbar*)sharedManager.mainTabbar;
    Navi *navi = (Navi*)[tab.childViewControllers objectAtIndex:0];
    homePage = (Home*)[navi.childViewControllers objectAtIndex:0];
    
    //NSLog(@"What %@",[tab.childViewControllers objectAtIndex:0]);
    
    [headerTitle setAttributedText:[self shorttext:headerTitle.text withFont:[UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+4]]];
    
    [swapBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [swapBtn.titleLabel setAttributedText:[self shorttext:swapBtn.titleLabel.text withFont:[UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+4]]];
    
    //[fromField setAttributedText:[self shorttext:fromField.text withFont:nil]];
    //[toField setAttributedText:[self shorttext:toField.text withFont:nil]];
    
    [self clearValue];
}

-(void)clearValue
{
    fromField.text = @"";              fromID = @"";
    toField.text = @"";                toID = @"";
    
    distance = @"";
    duration = @"";
    goDate = @"";
    goDateEN = @"";
    goH = @"";
    goM = @"";
    remark = @"";
    
    [dateLabel setAttributedText:[self shorttext:dateLabel.text withFont:nil]];
    [timeLabel setAttributedText:[self shorttext:timeLabel.text withFont:nil]];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    //[locationManager requestAlwaysAuthorization];
    
    localeTH = [[NSLocale alloc] initWithLocaleIdentifier:@"th"];
    df = [[NSDateFormatter alloc] init];
    //df.dateStyle = NSDateFormatterShortStyle;
    [df setLocale:localeTH];
    
    dayPicker = [[UIDatePicker alloc]init];
    [dayPicker setDatePickerMode:UIDatePickerModeDate];
    [dayPicker setMinimumDate: [NSDate date]];
    [dayPicker setLocale:localeTH];
    dayPicker.calendar = [localeTH objectForKey:NSLocaleCalendar];
    dayPicker.tag = 1;
    [dayPicker addTarget:self action:@selector(datePickerValueChanged:)forControlEvents:UIControlEventValueChanged];
    
    timePicker = [[UIDatePicker alloc]init];
    [timePicker setDatePickerMode:UIDatePickerModeTime];
    [timePicker setLocale:localeTH];
    timePicker.tag = 2;
    [timePicker addTarget:self action:@selector(datePickerValueChanged:)forControlEvents:UIControlEventValueChanged];
    
    dateField.inputView = dayPicker;
    [df setDateFormat:@"dd MMM yyyy"];
    dateField.text = [df stringFromDate:[NSDate date]];
    
    timeField.inputView = timePicker;
    [df setDateFormat:@"HH : mm"];
    timeField.text = [df stringFromDate:[NSDate date]];
    
    remarkTitle.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+3];
    [self shorttext:remarkTitle];
    
    remarkText.delegate = self;
    remarkText.text = @"";
    remarkText.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2];
    remarkText.layer.borderWidth = 1.0f;
    remarkText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [df setDateFormat:@"yyyy-MM-dd"];
    goDate = [df stringFromDate:[NSDate date]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    goH = [NSString stringWithFormat:@"%ld",(long)[components hour]];
    goM = [NSString stringWithFormat:@"%ld",(long)[components minute]];
    
    sharedManager.clearRequest = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self addbottomBorder:fromField withColor:[UIColor colorWithRed:75.0/255 green:195.0/255 blue:248.0/255 alpha:1]];
    [self addbottomBorder:toField withColor:nil];
    
    [self addbottomBorder:dateField withColor:nil];
    [self addbottomBorder:timeField withColor:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"Start");
    
    if (textField.tag == 101||textField.tag == 102) {
        nowEdit = textField.tag;
        
        GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
        acController.delegate = self;
        acController.tableCellBackgroundColor = [UIColor whiteColor];
        GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
        //filter.type = kGMSPlacesAutocompleteTypeFilterRegion;
        filter.country = @"TH";
        acController.autocompleteFilter = filter;
        [self presentViewController:acController animated:YES completion:nil];
    }
}

- (BOOL)textFieldDidChange:(UITextField *)textField
{
    NSLog(@"Change %@", textField.text);
    [textField setAttributedText:[self shorttext:textField.text withFont:nil]];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"End");
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

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    
    NSLog(@"Place ID %@", place.placeID);
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    
    if (nowEdit == 101) {
        fromField.text = place.name;
        fromID = place.placeID;
    }
    if (nowEdit == 102) {
        toField.text = place.name;
        toID = place.placeID;
    }
    
    if (![toField.text isEqualToString:@""] && ![fromField.text isEqualToString:@""]) {
        [self getDistance];
    }
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)getDistance
{
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@RequestDirection",HOST_DOMAIN];
    NSDictionary *parameters = @{@"ori":fromID,
                                 @"des":toID
                                 };
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"distance %@",responseObject);
         distance = [[[responseObject objectForKey:@"data"] objectAtIndex:0] objectForKey:@"allKm"];
         distance = [NSString stringWithFormat:@"%.1f กม.",[distance floatValue]];
         
         [HUD dismissAnimated:YES];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [HUD dismissAnimated:YES];
         [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
     }];
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
            NSLog(@"%@:%@",goH,goM);
            break;
    }
}

- (UITextField*)addbottomBorder:(UITextField*)textField withColor:(UIColor*)color
{
    textField.delegate = self;
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, textField.frame.size.height - 1, textField.frame.size.width, 1.0f);
    
    if (color == nil) {
        bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1].CGColor;
    }
    else{
        bottomBorder.backgroundColor = color.CGColor;
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, targetBtn.frame.size.width, 20)];
        textField.rightView = paddingView;
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
    
    [textField.layer addSublayer:bottomBorder];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    textField.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2];
    
    return textField;
}

- (IBAction)locationClick:(id)sender
{
    //UIButton *button = (UIButton *)sender;
    
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ไม่สามารถใช้งานได้" message:@"เนื่องจากคุณไม่อนุญาติให้แอพ Pamba เข้าถึงตำแหน่งปัจจุบันของคุณ" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            }];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
            
            [HUD dismissAnimated:YES];
            return;
        }
        fromField.text = @"ไม่พบชื่อสถานที่ปัจจุบัน";
        //toField.text = @"";
        
        if (placeLikelihoodList != nil) {
            GMSPlace *place = [[[placeLikelihoodList likelihoods] firstObject] place];
            if (place != nil) {
                fromID = place.placeID;
                fromField.text = place.name;
                //toField.text = [[place.formattedAddress componentsSeparatedByString:@", "] componentsJoinedByString:@"\n"];
                [HUD dismissAnimated:YES];
            }
        }
    }];
}

- (IBAction)swapClick:(id)sender
{
    //UIButton *button = (UIButton *)sender;
    NSString *fromText = fromField.text;
    NSString *toText = toField.text;
    NSString *beforeFromID = fromID;
    NSString *beforeToID = toID;
    
    fromField.text = toText;
    toField.text = fromText;
    fromID = beforeToID;
    toID = beforeFromID;
    
    [self getDistance];
}

- (IBAction)orangeClick:(id)sender
{
    if ([fromField.text isEqualToString:@""]||[toField.text isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ยังไม่ได้กำหนดจุดเริ่มต้นหรือปลายทาง" message:@"กรุณากำหนดจุดเริ่มต้นและปลายทางให้เรียบร้อย" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
        }];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        if ([remarkText.text isEqualToString:@"ใส่รายละเอียด..."]) {
            remark = @"";
        }
        else
        {
            remark = remarkText.text;
        }
        
        NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
        [df1 setLocale:localeTH];
        [df1 setDateFormat:@"yyyy-MM-dd"];
        NSDate *ceYear = [df1 dateFromString:goDate];
        
        localeEN = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
        [df2 setLocale:localeEN];
        [df2 setDateFormat:@"yyyy-MM-dd"];
        goDateEN = [df2 stringFromDate:ceYear];
        
        NSLog(@"userID:%@\n From:%@\n To:%@\n distance:%@\n duration:%@\n origin:%@\n destination:%@\n goDate:%@\n goH:%@\n goM:%@\n remark:%@",sharedManager.memberID,fromField.text,toField.text,distance,duration,fromID,toID,goDateEN,goH,goM,remark);
        
         HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
         HUD.textLabel.text = @"Loading";
         [HUD showInView:self.view];
         
         UIWebView *myWebview = [[UIWebView alloc]init];
         NSString* strUrl = [NSString stringWithFormat:@"%@webApi/findLatLng?user=%@&ori=%@&des=%@",HOST_DOMAIN_INDEX,sharedManager.memberID,fromID,toID];
         NSURL *url = [NSURL URLWithString:strUrl];
         myWebview.delegate = self;
         requestURL = [[NSURLRequest alloc] initWithURL:url];
         [myWebview loadRequest:requestURL];
         [self.view addSubview:myWebview];
         myWebview.hidden = YES;
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Did start loading: %@", [[request URL] absoluteString]);
    
    NSString *chkStr = [NSString stringWithFormat:@"%@ajax/echo_java.php",HOST_DOMAIN_HOME];
    
    if ([[[request URL] absoluteString] isEqualToString:chkStr]) {
        webLoaded = YES;
    }
    else{
        webLoaded = NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"Web Finish Load");
    //self.view.alpha = 1.f;
    if (webLoaded == YES)
    {
        [self finishRequest];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"!DidFailLoadWithError: %@", [error description]);
    //self.view.alpha = 1.f;
    [HUD dismissAnimated:YES];
    
    [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
}

- (void)finishRequest
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@createRequest",HOST_DOMAIN];
    NSDictionary *parameters = @{@"userEmail":sharedManager.memberID,
                                 @"From":fromField.text,
                                 @"To":toField.text,
                                 @"distance":distance,
                                 @"duration":duration,
                                 @"start_address":@"",
                                 @"end_address":@"",
                                 @"origin":fromID,
                                 @"destination":toID,
                                 @"goDate":goDateEN,
                                 @"goH":goH,
                                 @"goM":goM,
                                 @"remark":remark
                                 };
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"Request %@",responseObject);
         
         HUD.textLabel.text = @"ความต้องการที่นั่งถูกบันทึกแล้ว";
         HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
         [HUD dismissAfterDelay:3.0 animated:YES];
         
         sharedManager.reloadRequest = YES;
         sharedManager.clearRequest = YES;
         [self clearValue];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [HUD dismissAnimated:YES];
         [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
     }];
    webLoaded = NO;
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
