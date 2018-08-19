//
//  Profile.m
//  Pamba
//
//  Created by Firststep Consulting on 7/14/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "Profile.h"
#import "Web.h"
#import "UIImageView+WebCache.h"
#import "RightMenu.h"

@interface Profile ()

@end

@implementation Profile

@synthesize bgView,headerView,headerTitle,myScroll,myPage,profileTitle,profileEdit,profilePic,profileCamera,star1,star2,star3,star4,star5,reviewCount,profileNameL,profileUniversityL,profileGenderL,profileEmailL,profileTelL,profileNameR,profileUniversityR,profileGenderR,profileEmailR,profileTelR,verifyTitle,checkImg1,checkLabel1,checkImg2,checkLabel2,checkImg3,checkLabel3,checkImg4,checkLabel4,carTitle,carEdit,carDetail,backBtn;

- (void)viewWillLayoutSubviews
{
    //Circle
    profilePic.layer.cornerRadius = profilePic.frame.size.width/2;
    profilePic.layer.masksToBounds = YES;
    
    //Border
    //profilePic.layer.borderWidth = 3.0f;
    //profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    
    myScroll.contentSize = CGSizeMake(myScroll.frame.size.width*picNumber,myScroll.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = NO;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Profile"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self loadProfile];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sharedManager = [Singleton sharedManager];
    
    self.tabBarController.tabBar.hidden = YES;
    
    [backBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    headerTitle.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+4];
    [self shorttext:headerTitle];
    
    profileTitle.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+2];
    
    profilePic.hidden = NO;
    profileCamera.hidden = NO;
    
    [self updateProfile];
}

- (void)loadProfile
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@viewProfile",HOST_DOMAIN];
    NSDictionary *parameters = @{@"uid":sharedManager.memberID,
                                 @"me":@"1"
                                 };
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"profileJSON %@",responseObject);
         sharedManager.profileJSON = [[[responseObject objectForKey:@"data"] objectAtIndex:0] mutableCopy];
         [HUD dismissAnimated:YES];
         
         [self updateProfile];
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

- (void)updateProfile
{
    profilePic.image = [UIImage imageWithCIImage:[CIImage imageWithContentsOfURL:[NSURL URLWithString:[sharedManager.profileJSON objectForKey:@"userPic"]]]];
    //[profilePic sd_setImageWithURL:[NSURL URLWithString:[sharedManager.profileJSON objectForKey:@"userPic"]] placeholderImage:[UIImage imageNamed:@"icon1024.png"]];
    
    reviewCount.text = [NSString stringWithFormat:@"(%@ รีวิว)",[[[sharedManager.profileJSON objectForKey:@"rate"]objectAtIndex:0] objectForKey:@"total_review"]];
    
    int star = [[[[sharedManager.profileJSON objectForKey:@"rate"] objectAtIndex:0] objectForKey:@"rate"] intValue];
    
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
    
    reviewCount.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    profileNameL.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    profileGenderL.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    profileEmailL.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    profileTelL.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    profileUniversityL.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    
    profileNameR.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    profileGenderR.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    profileEmailR.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    profileTelR.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    profileUniversityR.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    
    profileNameR.text = [NSString stringWithFormat:@"%@ %@",[sharedManager.profileJSON objectForKey:@"forename"],[sharedManager.profileJSON objectForKey:@"surname"]];
    profileGenderR.text = [sharedManager.profileJSON objectForKey:@"gender"];
    profileEmailR.text = [sharedManager.profileJSON objectForKey:@"email"];
    profileTelR.text = [sharedManager.profileJSON objectForKey:@"mobile"];
    profileUniversityR.text = [sharedManager.profileJSON objectForKey:@"university"];
    
    verifyTitle.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+2];
    checkLabel1.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    checkLabel2.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    checkLabel3.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    checkLabel4.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    
    int x = 501;
    
    checkImg1.hidden = YES;
    checkImg2.hidden = YES;
    checkImg3.hidden = YES;
    checkImg4.hidden = YES;
    checkLabel1.hidden = YES;
    checkLabel2.hidden = YES;
    checkLabel3.hidden = YES;
    checkLabel4.hidden = YES;
    
    if ([[sharedManager.profileJSON objectForKey:@"checkTelActive"] intValue] != 0) {
        UIImageView *img = (UIImageView *)[self.view viewWithTag:x];
        UILabel *label = (UILabel *)[self.view viewWithTag:x+10];
        label.text = @"เบอร์โทรมือถือ";
        img.hidden = NO;
        label.hidden = NO;
        x++;
    }
    if ([[sharedManager.profileJSON objectForKey:@"checkFBconnect"] intValue] != 0) {
        UIImageView *img = (UIImageView *)[self.view viewWithTag:x];
        UILabel *label = (UILabel *)[self.view viewWithTag:x+10];
        label.text = @"Facebook";
        img.hidden = NO;
        label.hidden = NO;
        x++;
    }
    if ([[sharedManager.profileJSON objectForKey:@"checkEmailActive"] intValue] != 0) {
        UIImageView *img = (UIImageView *)[self.view viewWithTag:x];
        UILabel *label = (UILabel *)[self.view viewWithTag:x+10];
        label.text = @"อีเมลล์";
        img.hidden = NO;
        label.hidden = NO;
        x++;
    }
    if ([[sharedManager.profileJSON objectForKey:@"checkidCard"] intValue] != 0) {
        UIImageView *img = (UIImageView *)[self.view viewWithTag:x];
        UILabel *label = (UILabel *)[self.view viewWithTag:x+10];
        label.text = @"บัตรประชาชน";
        img.hidden = NO;
        label.hidden = NO;
        x++;
    }
    
    carTitle.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+2];
    //carDetail.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
    
    NSDictionary *carArray = [[sharedManager.profileJSON objectForKey:@"carDetail"] objectAtIndex:0];
    
    if ([carArray objectForKey:@"error"]) {
        // contains object
        carDetail.text = [carArray objectForKey:@"error"];
    }
    else{
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
        
        
        NSMutableArray *picArray = [carArray objectForKey:@"pic"];
        
        for (UIView *v in myScroll.subviews) {
            if ([v isKindOfClass:[UIImageView class]]) {
                [v removeFromSuperview];
            }
        }
        
        for (int i=0; i<[picArray count]; i++)
        {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(myScroll.frame.size.width*i, 0, myScroll.frame.size.width, myScroll.frame.size.height)];
            
            [imgView sd_setImageWithURL:[NSURL URLWithString:[[picArray objectAtIndex:i] objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"xicon1024.png"]];
            
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            
            [myScroll addSubview:imgView];
        }
        picNumber = [picArray count];
        myPage.numberOfPages = [picArray count];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = myScroll.frame.size.width; // you need to have a **iVar** with getter for scrollView
    float fractionalPage = myScroll.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    myPage.currentPage = page; // you need to have a **iVar** with getter for pageControl
}

- (IBAction)profileEdit:(id)sender
{
    Web *web = [self.storyboard instantiateViewControllerWithIdentifier:@"Web"];
    web.webTitle = @"แก้ไขข้อมูล";
    web.urlString = [NSString stringWithFormat:@"%@profileWebview/viewProfile?userEmail=%@",HOST_DOMAIN_INDEX,sharedManager.memberID];
    [self.navigationController pushViewController:web animated:YES];
}

- (IBAction)cameraUpload:(id)sender
{
    Web *web = [self.storyboard instantiateViewControllerWithIdentifier:@"Web"];
    web.webTitle = @"แก้ไขข้อมูล";
    web.urlString = [NSString stringWithFormat:@"%@ProfileWebview/edit?userEmail=%@",HOST_DOMAIN_INDEX,sharedManager.memberID];
    [self.navigationController pushViewController:web animated:YES];
}

- (IBAction)carEdit:(id)sender
{
    Web *web = [self.storyboard instantiateViewControllerWithIdentifier:@"Web"];
    web.webTitle = @"แก้ไขข้อมูล";
    web.urlString = [NSString stringWithFormat:@"%@ProfileWebview/carEdit?userEmail=%@",HOST_DOMAIN_INDEX,sharedManager.memberID];
    [self.navigationController pushViewController:web animated:YES];
}

- (IBAction)back:(id)sender
{
    RightMenu *rm = (RightMenu*)[sharedManager.mainRoot.childViewControllers objectAtIndex:0];
    [rm loadProfile];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UILabel *)shorttext:(UILabel *)originalLabel
{
    if (![originalLabel.text isKindOfClass:[NSNull class]]) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:originalLabel.text];
        [text addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:-0.5] range:NSMakeRange(0, text.length)];
        [originalLabel setAttributedText:text];
    }
    else{
        
    }
    return originalLabel;
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
