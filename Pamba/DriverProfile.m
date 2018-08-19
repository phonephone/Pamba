//
//  DriverProfile.m
//  Pamba
//
//  Created by Firststep Consulting on 7/18/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "DriverProfile.h"
#import "UIImageView+WebCache.h"
#import "Web.h"

@interface DriverProfile ()

@end

@implementation DriverProfile

@synthesize userType,driverID,bgView,headerView,headerTitle,myScroll,myPage,profilePic,star1,star2,star3,star4,star5,reviewCount,verifyTitle,checkImg1,checkLabel1,checkImg2,checkLabel2,checkImg3,checkLabel3,checkImg4,checkLabel4,carDetail,profileName,universityName,offerCount,requestCount,orangeBtn,backBtn;

- (void)viewWillLayoutSubviews
{
    //Circle
    profilePic.layer.cornerRadius = profilePic.frame.size.width/2;
    profilePic.layer.masksToBounds = YES;
    
    //fbPic.layer.cornerRadius = profilePic.frame.size.height/2;
    //fbPic.layer.masksToBounds = YES;
    
    //Border
    //profilePic.layer.borderWidth = 3.0f;
    //profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)viewDidLayoutSubviews
{
    myScroll.contentSize = CGSizeMake(myScroll.frame.size.width*picNumber,myScroll.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = NO;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"DriverProfile"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sharedManager = [Singleton sharedManager];
    
    self.tabBarController.tabBar.hidden = YES;
    
    [backBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    if ([userType isEqualToString:@"driver"]) {
        headerTitle.text = @"ข้อมูลผู้ขับ";
        [orangeBtn setImage:[UIImage imageNamed:@"driver_contact"] forState:UIControlStateNormal];
    }
    else
    {
        headerTitle.text = @"ข้อมูลผู้โดยสาร";
        [orangeBtn setImage:[UIImage imageNamed:@"passenger_contact"] forState:UIControlStateNormal];
    }
    
    headerTitle.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+4];
    [self shorttext:headerTitle];
    
    //[orangeBtn.titleLabel setFont:[UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+6]];
    [orangeBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    profileName.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+2];
    
    reviewCount.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    
    universityName.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    offerCount.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    requestCount.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    
    verifyTitle.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+2];
    checkLabel1.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    checkLabel2.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    checkLabel3.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    checkLabel4.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    
    carDetail.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    
    [self loadProfile];
}

- (void)loadProfile
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@viewProfile",HOST_DOMAIN];
    NSDictionary *parameters = @{@"uid":driverID,
                                 @"me":@"0"
                                 };
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"driverJSON %@",responseObject);
         driverJSON = [[[responseObject objectForKey:@"data"] objectAtIndex:0] mutableCopy];
         carArray = [[driverJSON objectForKey:@"carDetail"] objectAtIndex:0];
         
         [self setDriver];
         
         [HUD dismissAnimated:YES];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [HUD dismissAnimated:YES];
         
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"เกิดข้อผิดพลาด" message:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง" preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
             
             [self loadProfile];
         }];
         [alertController addAction:ok];
         
         [self presentViewController:alertController animated:YES completion:nil];
         
     }];
}

- (void)setDriver
{
    profilePic.image = [UIImage imageWithCIImage:[CIImage imageWithContentsOfURL:[NSURL URLWithString:[driverJSON objectForKey:@"userPic"]]]];
    //[profilePic sd_setImageWithURL:[NSURL URLWithString:[driverJSON objectForKey:@"userPic"]] placeholderImage:[UIImage imageNamed:@"icon1024.png"]];
    
    profileName.text = [driverJSON objectForKey:@"name"];
    
    NSString *university = [driverJSON objectForKey:@"university"];
    if ([university isEqualToString:@"ไม่ระบุ"]) {
        universityName.text = @"ไม่ระบุมหาวิทยาลัย";
    }
    else
    {
        universityName.text = [NSString stringWithFormat:@"มหาวิทยาลัย%@",university];
    }
    
    reviewCount.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    reviewCount.text = [NSString stringWithFormat:@"(%@ รีวิว)",[[[driverJSON objectForKey:@"rate"]objectAtIndex:0] objectForKey:@"total_review"]];
    
    int star = [[[[driverJSON objectForKey:@"rate"] objectAtIndex:0] objectForKey:@"rate"] intValue];
    
    UIImage *starON = [UIImage imageNamed:@"cell_star"];
    UIImage *starOFF = [UIImage imageNamed:@"cell_star_off"];
    star1.image = starOFF;
    star2.image = starOFF;
    star3.image = starOFF;
    star4.image = starOFF;
    star5.image = starOFF;
    
    switch (star) {
        case 0:
            break;
            
        case 1:
            star1.image = starON;
            break;
            
        case 2:
            star1.image = starON;
            star2.image = starON;
            break;
            
        case 3:
            star1.image = starON;
            star2.image = starON;
            star3.image = starON;
            break;
            
        case 4:
            star1.image = starON;
            star2.image = starON;
            star3.image = starON;
            star4.image = starON;
            break;
            
        case 5:
            star1.image = starON;
            star2.image = starON;
            star3.image = starON;
            star4.image = starON;
            star5.image = starON;
            break;
            
        default:
            star1.image = starON;
            star2.image = nil;
            star3.image = starON;
            star4.image = nil;
            star5.image = starON;
            break;
    }
    
    offerCount.text = [NSString stringWithFormat:@"เสนอที่นั่ง %@ ครั้ง",[driverJSON objectForKey:@"totalOffer"]];
    requestCount.text = [NSString stringWithFormat:@"โดยสารรถ %@ ครั้ง",[driverJSON objectForKey:@"totalRequest"]];
    
    for (UIView *v in myScroll.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            [v removeFromSuperview];
        }
    }
    
    NSMutableArray *picArray = [carArray objectForKey:@"pic"];
    for (int i=0; i<[picArray count]; i++)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(myScroll.frame.size.width*i, 0, myScroll.frame.size.width, myScroll.frame.size.height)];
        
        [imgView sd_setImageWithURL:[NSURL URLWithString:[[picArray objectAtIndex:i] objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"xicon1024.png"]];
        
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        
        [myScroll addSubview:imgView];
    }
    picNumber = [picArray count];
    myPage.numberOfPages = [picArray count];
    
    
    NSString *car1 = @"ยี่ห้อ :";
    NSString *car2 = @"รุ่น :";
    NSString *car3 = @"ป้ายทะเบียน :";
    
    NSMutableAttributedString *attrString;
    NSMutableAttributedString *attrString2;
    NSMutableAttributedString *attrString3;
    
    if (![[carArray objectForKey:@"brand"] isEqualToString:@""]) {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@    ",car1,[carArray objectForKey:@"brand"]]];
    }
    else{
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ -    ",car1]];
    }
    
    if (![[carArray objectForKey:@"model"] isEqualToString:@""]) {
        attrString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@\n",car2,[carArray objectForKey:@"model"]]];
    }
    else{
        attrString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ -\n",car2]];
    }
    
    if (![[carArray objectForKey:@"plateNo"] isEqualToString:@""]) {
        attrString3 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",car3,[carArray objectForKey:@"plateNo"]]];
    }
    else{
        attrString3 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ -",car3]];
    }
    
    [attrString setAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize] } range:NSMakeRange(0, attrString.length)];
    [attrString setAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+1] } range:NSMakeRange(0, car1.length)];
    [attrString addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:-0.5] range:NSMakeRange(0, attrString.length)];
    
    [attrString2 setAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize] } range:NSMakeRange(0, attrString2.length)];
    [attrString2 setAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+1] } range:NSMakeRange(0, car2.length)];
    [attrString2 addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:-0.5] range:NSMakeRange(0, attrString2.length)];
    
    [attrString3 setAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize] } range:NSMakeRange(0, attrString3.length)];
    [attrString3 setAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+1] } range:NSMakeRange(0, car3.length)];
    [attrString3 addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:-0.5] range:NSMakeRange(0, attrString3.length)];
    
    [attrString appendAttributedString:attrString2];
    [attrString appendAttributedString:attrString3];
    
    [carDetail setAttributedText:attrString];
    
    int x = 501;
    
    checkImg1.hidden = YES;
    checkImg2.hidden = YES;
    checkImg3.hidden = YES;
    checkImg4.hidden = YES;
    checkLabel1.hidden = YES;
    checkLabel2.hidden = YES;
    checkLabel3.hidden = YES;
    checkLabel4.hidden = YES;
    
    if ([[driverJSON objectForKey:@"checkTelActive"] intValue] != 0) {
        UIImageView *img = (UIImageView *)[self.view viewWithTag:x];
        UILabel *label = (UILabel *)[self.view viewWithTag:x+10];
        label.text = @"เบอร์โทรมือถือ";
        img.hidden = NO;
        label.hidden = NO;
        x++;
    }
    if ([[driverJSON objectForKey:@"checkFBconnect"] intValue] != 0) {
        UIImageView *img = (UIImageView *)[self.view viewWithTag:x];
        UILabel *label = (UILabel *)[self.view viewWithTag:x+10];
        label.text = @"Facebook";
        img.hidden = NO;
        label.hidden = NO;
        x++;
    }
    if ([[driverJSON objectForKey:@"checkEmailActive"] intValue] != 0) {
        UIImageView *img = (UIImageView *)[self.view viewWithTag:x];
        UILabel *label = (UILabel *)[self.view viewWithTag:x+10];
        label.text = @"อีเมลล์";
        img.hidden = NO;
        label.hidden = NO;
        x++;
    }
    if ([[driverJSON objectForKey:@"checkidCard"] intValue] != 0) {
        UIImageView *img = (UIImageView *)[self.view viewWithTag:x];
        UILabel *label = (UILabel *)[self.view viewWithTag:x+10];
        label.text = @"บัตรประชาชน";
        img.hidden = NO;
        label.hidden = NO;
        x++;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = myScroll.frame.size.width; // you need to have a **iVar** with getter for scrollView
    float fractionalPage = myScroll.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    myPage.currentPage = page; // you need to have a **iVar** with getter for pageControl
}

- (IBAction)orangeClick:(id)sender
{
    NSLog(@"Contact");
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"โทร" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *telNumber = [NSString stringWithFormat:@"tel:%@",[driverJSON objectForKey:@"mobile"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telNumber]];
        
        // Call button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"แชท" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        Web *web = [self.storyboard instantiateViewControllerWithIdentifier:@"Web"];
        web.webTitle = @"ติดต่อผู้ขับ";
        web.urlString = [NSString stringWithFormat:@"%@ChatWV/message?userFrom=%@&userTo=%@",HOST_DOMAIN_INDEX,sharedManager.memberID,[driverJSON objectForKey:@"user"]];
        [web setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self.navigationController pushViewController:web animated:YES];
        
        // Chat button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"ยกเลิก" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
