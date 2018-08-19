//
//  Register.m
//  Pamba
//
//  Created by Firststep Consulting on 7/31/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "Register.h"
#import "Login.h"
#import "RightMenu.h"
#import "Tabbar.h"

@interface Register ()

@end

@implementation Register

@synthesize bgView,headerView,headerTitle,headerLabel,genderLabel,firstnameLabel,lastnameLabel,universityLabel,maleBtn,femaleBtn,firstnameField,lastnameField,universityField,registerBtn;

- (void)viewWillAppear:(BOOL)animated
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Register"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sharedManager = [Singleton sharedManager];
    
    headerTitle.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+4];
    
    NSString *fontName = @"Kanit-Regular";
    
    headerLabel.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+5];
    genderLabel.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+3];
    
    firstnameLabel.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+1];
    lastnameLabel.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+1];
    universityLabel.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+1];
    
    firstnameField.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+1];
    lastnameField.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+1];
    universityField.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+1];
    
    [self addbottomBorder:firstnameField];
    [self addbottomBorder:lastnameField];
    [self addbottomBorder:universityField];
    
    [maleBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [femaleBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    gender = @"male";
    
    universityPicker = [[UIPickerView alloc]init];
    universityPicker.delegate = self;
    universityPicker.dataSource = self;
    [universityPicker setShowsSelectionIndicator:YES];
    universityPicker.tag = 0;
    universityField.inputView = universityPicker;
    
    universityID = @"";
    universityName = @"";
    
    [self loadUniversity];
}

- (void)loadUniversity
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@university_list",HOST_DOMAIN];
    
    NSDictionary *parameters = @{};
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"UniversityJSON %@",responseObject);
         
         if ([[responseObject objectForKey:@"status"]isEqualToString:@"success"]) {
             universityJSON = [responseObject objectForKey:@"data"];
             universityField.text = [[universityJSON objectAtIndex:0] objectForKey:@"university_name"];
             universityID = [[universityJSON objectAtIndex:0] objectForKey:@"university_id"];
             universityName = universityField.text;
             [universityPicker selectRow:0 inComponent:0 animated:YES];
         }
         [HUD dismissAnimated:YES];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
         [HUD dismissAnimated:YES];
     }];
}

- (long)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (long)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    long rowNum = 0;
    
    switch (pickerView.tag) {
            
        case 0://University
            rowNum = [universityJSON count];
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
            
        case 0://University
            rowTitle = [[universityJSON objectAtIndex:row] objectForKey:@"university_name"];
            break;
            
        default:
            break;
    }
    
    return rowTitle;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (pickerView.tag) {
            
        case 0://Extime
            universityField.text = [[universityJSON objectAtIndex:row] objectForKey:@"university_name"];
            universityID = [[universityJSON objectAtIndex:row] objectForKey:@"university_id"];
            universityName = universityField.text;
            break;
            
        default:
            break;
    }
}

- (IBAction)maleClick:(id)sender
{
    [maleBtn setImage:[UIImage imageNamed:@"register_check_on"] forState:UIControlStateNormal];
    [femaleBtn setImage:[UIImage imageNamed:@"register_check_off"] forState:UIControlStateNormal];
    gender = @"male";
}

- (IBAction)femaleClick:(id)sender
{
    [maleBtn setImage:[UIImage imageNamed:@"register_check_off"] forState:UIControlStateNormal];
    [femaleBtn setImage:[UIImage imageNamed:@"register_check_on"] forState:UIControlStateNormal];
    gender = @"female";
}

- (IBAction)registerClick:(id)sender
{
    NSLog(@"%@ %@ %@ %@\n%@ %@",sharedManager.memberID,gender,firstnameField.text,lastnameField.text,universityID,universityName);
    
    if ([firstnameField.text length] < 1 || [lastnameField.text length] < 1)
    {
        [self alertTitle:@"ข้อมูลไม่ครบ" detail:@"กรุณาใส่ชื่อและนามสกุล"];
    }
    else{
        [self loadRegister];
    }
}

- (void)loadRegister
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@user_block_saveDetail",HOST_DOMAIN];
    
    NSDictionary *parameters = @{@"forename":firstnameField.text,@"surname":lastnameField.text,@"gender":gender,@"user_id":sharedManager.memberID,@"university_id":universityID};
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"RegisterJSON %@",responseObject);
         
         if ([[responseObject objectForKey:@"status"]isEqualToString:@"success"]) {
             
             sharedManager.loginStatus = YES;
             
             NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
             [ud setBool:sharedManager.loginStatus forKey:@"loginStatus"];
             [ud setObject:sharedManager.memberID forKey:@"memberID"];
             [ud synchronize];
             
             Tabbar *tab = [self.storyboard instantiateViewControllerWithIdentifier:@"tabbarController"];
             [self.menuContainerViewController setCenterViewController:tab];
         }
         else{
             [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาลองใหม่อีกครั้ง"];
         }
         [HUD dismissAnimated:YES];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
         [HUD dismissAnimated:YES];
     }];
}

- (UITextField*)addbottomBorder:(UITextField*)textField
{
    textField.delegate = self;
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, textField.frame.size.height - 1, textField.frame.size.width*1.1, 1.0f);
    
    bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1].CGColor;
    
    [textField.layer addSublayer:bottomBorder];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    return textField;
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
