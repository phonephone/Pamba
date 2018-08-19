//
//  Login.m
//  Pamba
//
//  Created by Firststep Consulting on 7/31/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "Login.h"
#import "Register.h"
#import "Tabbar.h"
#import "RightMenu.h"

@interface Login ()

@end

@implementation Login

@synthesize headerLabel,otpLabel,mobileField,otpField,requestOTPBtn,submitOTPBtn,cancelOTPBtn;

- (void)viewDidLayoutSubviews
{
    NSString *fontName = @"Kanit-Regular";
    headerLabel.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+5];
    mobileField.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+1];
    requestOTPBtn.titleLabel.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+3];
    
    otpLabel.font = [UIFont fontWithName:fontName size:sharedManager.fontSize-1];
    otpField.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+1];
    submitOTPBtn.titleLabel.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+3];
    cancelOTPBtn.titleLabel.font = [UIFont fontWithName:fontName size:sharedManager.fontSize+3];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sharedManager = [Singleton sharedManager];
    
    mobileField.borderStyle = UITextBorderStyleRoundedRect;
    otpField.borderStyle = UITextBorderStyleRoundedRect;
    otpLabel.hidden = YES;
    otpField.hidden = YES;
    submitOTPBtn.hidden = YES;
    cancelOTPBtn.hidden = YES;
    //mobileField.text = @"88888888";
    //otpField.text = @"545720";
    
    waitOTP = NO;
}

-(void)timerCalled
{
    waitOTP = NO;
}

- (IBAction)otpClick:(id)sender
{
    if ([mobileField.text isEqualToString:@"88888888"])//Demo
    {
        sharedManager.memberID = @"1";
        sharedManager.loginStatus = YES;
        
        Tabbar *tab = [self.storyboard instantiateViewControllerWithIdentifier:@"tabbarController"];
        [self.menuContainerViewController setCenterViewController:tab];
    }
    else if ([mobileField.text length] < 10)
    {
        [self alertTitle:@"ข้อมูลไม่ถูกต้อง" detail:@"กรุณาใส่เบอร์โทรศัพท์มือถือให้ครบถ้วน"];
    }
    else if (waitOTP == YES)
    {
        [self alertTitle:@"ไม่สามารถทำรายการได้" detail:@"กรุณาลองใหม่อีกครั้งหลังจากผ่านไป 1 นาที"];
    }
    else{
        /*
        [mobileField resignFirstResponder];
        requestOTPBtn.hidden = YES;
        otpLabel.hidden = NO;
        otpField.hidden = NO;
        submitOTPBtn.hidden = NO;
        cancelOTPBtn.hidden = NO;
        waitOTP = YES;
        [self performSelector:@selector(timerCalled) withObject:nil afterDelay:60.0];
         */
        [self loadOTP];
    }
}

- (void)loadOTP
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@getOTP",HOST_DOMAIN];
    
    NSDictionary *parameters = @{@"phone":mobileField.text};
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"OTPJSON %@",responseObject);
         
         if ([[responseObject objectForKey:@"status"]isEqualToString:@"success"]) {
             [mobileField resignFirstResponder];
             requestOTPBtn.hidden = YES;
             otpLabel.hidden = NO;
             otpField.hidden = NO;
             submitOTPBtn.hidden = NO;
             cancelOTPBtn.hidden = NO;
             waitOTP = YES;
             [self performSelector:@selector(timerCalled) withObject:nil afterDelay:60.0];
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

- (IBAction)loginClick:(id)sender
{
    if ([otpField.text length] < 4)
    {
        [self alertTitle:@"ข้อมูลไม่ถูกต้อง" detail:@"กรุณาใส่รหัส OTP ให้ครบถ้วน"];
    }
    else{
        [self loadLogin:@"OTP"];
    }
}

- (void)loadLogin:(NSString*)mode
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@login",HOST_DOMAIN];
    
    NSDictionary *parameters;
    if ([mode isEqualToString:@"OTP"]) {
        parameters = @{@"phone":mobileField.text,@"otp":otpField.text};
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"LoginJSON %@",responseObject);
         loginJSON = [[responseObject objectForKey:@"data"] objectAtIndex:0];
         
         if ([[responseObject objectForKey:@"status"]isEqualToString:@"success"]) {
             sharedManager.memberID = [loginJSON objectForKey:@"user_id"];
             [self loginSuccess];
         }
         else{
             [self alertTitle:@"รหัส OTP ไม่ถูกต้อง" detail:@"กรุณาตรวจสอบรหัส OTP ของท่านแล้วลองใหม่อีกครั้ง"];
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

- (void)loginSuccess
{
    if ([[loginJSON objectForKey:@"check_detail"]isEqualToString:@"0"]) { //Regis
        Register *reg = [self.storyboard instantiateViewControllerWithIdentifier:@"Register"];
        [self.menuContainerViewController setCenterViewController:reg];
    }
    else //Home
    {
        sharedManager.loginStatus = YES;
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setBool:sharedManager.loginStatus forKey:@"loginStatus"];
        [ud setObject:sharedManager.memberID forKey:@"memberID"];
        [ud synchronize];
        
        //RightMenu *rm = (RightMenu*)[sharedManager.mainRoot.childViewControllers objectAtIndex:0];
        //[rm loadProfile];
        
        Tabbar *tab = [self.storyboard instantiateViewControllerWithIdentifier:@"tabbarController"];
        [self.menuContainerViewController setCenterViewController:tab];
    }
}

- (IBAction)cancelClick:(id)sender
{
    requestOTPBtn.hidden = NO;
    otpLabel.hidden = YES;
    otpField.hidden = YES;
    submitOTPBtn.hidden = YES;
    cancelOTPBtn.hidden = YES;
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
