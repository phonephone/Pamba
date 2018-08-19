//
//  ProfileOffer.m
//  Pamba
//
//  Created by Firststep Consulting on 7/30/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "ProfileOffer.h"
#import "ProfileOfferDetail.h"
#import "ListCell.h"
#import "ReserveCell.h"
#import "OfferDetail.h"
#import "RequestDetail.h"
#import "UIImageView+WebCache.h"
#import <CCMPopup/CCMPopupSegue.h>
#import "RightMenu.h"

@interface ProfileOffer ()

@end

@implementation ProfileOffer

@synthesize mode,bgView,headerView,headerTitle,mycollectionView,noresultLabel,backBtn;

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    startScrollViewYOffset = homePage.toolBar.frame.origin.y;
    
    [mycollectionView.collectionViewLayout collectionViewContentSize];
    mycollectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    [mycollectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    self.menuContainerViewController.panMode = NO;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"ProfileOffer"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self loadList];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sharedManager = [Singleton sharedManager];
    
    [backBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    Tabbar *tab = (Tabbar*)sharedManager.mainTabbar;
    Navi *navi = (Navi*)[tab.childViewControllers objectAtIndex:0];
    homePage = (Home*)[navi.childViewControllers objectAtIndex:0];
    
    if ([mode isEqualToString:@"Offer"]) {
        headerTitle.text = @"การเสนอที่นั่งของคุณ";
        NSLog(@"Your Offer");
    }
    
    if ([mode isEqualToString:@"Reserve"]) {
        headerTitle.text = @"การสำรองที่นั่งของคุณ";
        NSLog(@"Your Booking");
    }
    
    headerTitle.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+4];
    [self shorttext:headerTitle];
    
    noresultLabel.hidden = YES;
    noresultLabel.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+1];
    [self shorttext:noresultLabel];
    
    refreshController = [[UIRefreshControl alloc] init];
    [refreshController addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [mycollectionView addSubview:refreshController];
    
    
    localeTH = [[NSLocale alloc] initWithLocaleIdentifier:@"th"];
    df = [[NSDateFormatter alloc] init];
    //df.dateStyle = NSDateFormatterShortStyle;
    [df setLocale:localeTH];
    
    dayPicker = [[UIDatePicker alloc]init];
    [dayPicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [dayPicker setMinimumDate: [NSDate date]];
    [dayPicker setLocale:localeTH];
    dayPicker.calendar = [localeTH objectForKey:NSLocaleCalendar];
    dayPicker.tag = 1;
    [dayPicker addTarget:self action:@selector(datePickerValueChanged:)forControlEvents:UIControlEventValueChanged];
    
    dateField = [[UITextField alloc] init];
    dateField.inputView = dayPicker;
    dateField.delegate = self;
    [self.view addSubview:dateField];
}

-(void)handleRefresh : (id)sender
{
    NSLog (@"Pull To Refresh Method Called");
    [self loadList];
}

- (void)loadList
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    NSString* url;
    
    if ([mode isEqualToString:@"Offer"]) {
        url = [NSString stringWithFormat:@"%@ActiveOffer",HOST_DOMAIN];
    }
    
    if ([mode isEqualToString:@"Reserve"]) {
        url = [NSString stringWithFormat:@"%@ActiveReserve",HOST_DOMAIN];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"userEmail":sharedManager.memberID};
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"listJSON %@",responseObject);
         
         listJSON = [[responseObject objectForKey:@"data"] mutableCopy];
         [mycollectionView reloadData];
         
         [refreshController endRefreshing];
         [HUD dismissAnimated:YES];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [refreshController endRefreshing];
         [HUD dismissAnimated:YES];
         
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"เกิดข้อผิดพลาด" message:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง" preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
             
             [self loadList];
         }];
         [alertController addAction:ok];
         
         [self presentViewController:alertController animated:YES completion:nil];
         
     }];
}

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    long rowNo;
    if ([[[listJSON objectAtIndex:0] allKeys] containsObject:@"Error"]) {
        //ไม่มีรายการ
        rowNo = 0;
        
    }
    else{
        [mycollectionView reloadData];
        rowNo = [listJSON count];
    }
    
    if (rowNo == 0) { noresultLabel.hidden = NO; }
    else{ noresultLabel.hidden = YES; }
    
    return rowNo;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width = (mycollectionView.frame.size.width)*0.936;
    float height = width*0.485;
    CGSize itemSize = CGSizeMake(width,height);
    return itemSize;//mycollectionView.collectionViewLayout.collectionViewContentSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 0, 15, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 15.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15.0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *myCell;
    NSDictionary *cellArray = [listJSON objectAtIndex:indexPath.row];
    
    if ([mode isEqualToString:@"Offer"]) {//การเสนอที่นั่งของคุณ
        ListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCell" forIndexPath:indexPath];
        
        [cell.moreBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.moreBtn addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.moreBtn.tag = indexPath.row;
        
        cell.startLabel.text = [cellArray objectForKey:@"From"];
        cell.endLabel.text = [cellArray objectForKey:@"To"];
        cell.priceLabel.text = [cellArray objectForKey:@"price"];
        cell.dateLabel.text = [NSString stringWithFormat:@"%@ เวลา %@:%@ น.",[cellArray objectForKey:@"goDate"],[cellArray objectForKey:@"goH"],[cellArray objectForKey:@"goM"]];
        cell.seatLabel.text = [NSString stringWithFormat:@"%@ ที่นั่ง",[cellArray objectForKey:@"now_seat"]];
        
        [cell.alertBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.alertBtn addTarget:self action:@selector(alertClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.alertBtn.tag = indexPath.row;
        //cell.alertLabel.text = [cellArray objectForKey:@"notification"];
        cell.alertLabel.text = [NSString stringWithFormat:@"%@",[cellArray objectForKey:@"notification"]];
        
        [cell.duplicateBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.duplicateBtn addTarget:self action:@selector(copyClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.duplicateBtn.tag = indexPath.row;
        
        [cell.trashBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.trashBtn addTarget:self action:@selector(trashClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.trashBtn.tag = indexPath.row;
        
        cell.startLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1];
        [self shorttext:cell.startLabel];
        cell.endLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1];
        [self shorttext:cell.endLabel];
        cell.priceLabel.font = [UIFont fontWithName:@"Kanit-Bold" size:sharedManager.fontSize+21];
        [self shorttext:cell.priceLabel];
        cell.bahtLabel.font = [UIFont fontWithName:@"Kanit-Light" size:sharedManager.fontSize+4];
        [self shorttext:cell.bahtLabel];
        cell.dateLabel.font = [UIFont fontWithName:@"Kanit-Light" size:sharedManager.fontSize-3];
        [self shorttext:cell.dateLabel];
        cell.seatLabel.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize-2];
        [self shorttext:cell.seatLabel];
        cell.alertLabel.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize-2];
        [self shorttext:cell.alertLabel];
        
        myCell = cell;
    }
    
    if ([mode isEqualToString:@"Reserve"]) {//การสำรองที่นั่งของคุณ
        ReserveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReserveCell" forIndexPath:indexPath];
        
        [cell.moreBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.moreBtn addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.moreBtn.tag = indexPath.row;
        
        cell.startLabel.text = [cellArray objectForKey:@"From"];
        cell.endLabel.text = [cellArray objectForKey:@"To"];
        cell.priceLabel.text = [cellArray objectForKey:@"price"];
        cell.dateLabel.text = [NSString stringWithFormat:@"%@ เวลา %@:%@ น.",[cellArray objectForKey:@"goDate"],[cellArray objectForKey:@"goH"],[cellArray objectForKey:@"goM"]];
        cell.seatLabel.text = [NSString stringWithFormat:@"%@ ที่นั่ง",[cellArray objectForKey:@"now_seat"]];
        
        cell.statusLabel.text = [[cellArray objectForKey:@"request_status"] objectForKey:@"status_text"];
        if ([cell.statusLabel.text isEqualToString:@"รอ"]) {
            cell.statusLabel.textColor = [UIColor blackColor];
        }
        if ([cell.statusLabel.text isEqualToString:@"ยอมรับ"]) {
            cell.statusLabel.textColor = [UIColor colorWithRed:83.0/255 green:172.0/255 blue:10.0/255 alpha:1];
        }
        if ([cell.statusLabel.text isEqualToString:@"ปฏิเสธ"]) {
            cell.statusLabel.textColor = [UIColor colorWithRed:237.0/255 green:70.0/255 blue:47.0/255 alpha:1];
        }
        
        [cell.trashBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.trashBtn addTarget:self action:@selector(trashClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.trashBtn.tag = indexPath.row;
        
        cell.startLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1];
        [self shorttext:cell.startLabel];
        cell.endLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1];
        [self shorttext:cell.endLabel];
        cell.priceLabel.font = [UIFont fontWithName:@"Kanit-Bold" size:sharedManager.fontSize+21];
        [self shorttext:cell.priceLabel];
        cell.bahtLabel.font = [UIFont fontWithName:@"Kanit-Light" size:sharedManager.fontSize+4];
        [self shorttext:cell.bahtLabel];
        cell.dateLabel.font = [UIFont fontWithName:@"Kanit-Light" size:sharedManager.fontSize-3];
        [self shorttext:cell.dateLabel];
        cell.seatLabel.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize-2];
        [self shorttext:cell.seatLabel];
        cell.statusTitle.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2];
        [self shorttext:cell.statusTitle];
        cell.statusLabel.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+6];
        [self shorttext:cell.statusLabel];
        
        myCell = cell;
    }
    
    return myCell;
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"End");
    
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setLocale:localeTH];
    [df1 setDateFormat:@"yyyy-MM-dd"];
    goDate = [df1 stringFromDate:dayPicker.date];
    NSDate *ceYear = [df1 dateFromString:goDate];
    
    localeEN = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
    [df2 setLocale:localeEN];
    [df2 setDateFormat:@"yyyy-MM-dd"];
    goDateEN = [df2 stringFromDate:ceYear];
    
    [df setDateFormat:@"HH : mm"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:dayPicker.date];
    goH = [NSString stringWithFormat:@"%ld",(long)[components hour]];
    goM = [NSString stringWithFormat:@"%ld",(long)[components minute]];
    
    [self duplicate];
}

- (void)datePickerValueChanged:(UIDatePicker *)datePicker
{
    NSLog(@"Date %@",datePicker.date);
}

- (void)moreClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    //[self collectionView:mycollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:1]];
    
    OfferDetail *ofd = [self.storyboard instantiateViewControllerWithIdentifier:@"OfferDetail"];
    ofd.offerID = [[listJSON objectAtIndex:button.tag] objectForKey:@"id"];
    [self.navigationController pushViewController:ofd animated:YES];
}

- (void)alertClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSLog(@"Alert %ld",(long)button.tag);
    selectID = [[listJSON objectAtIndex:button.tag] objectForKey:@"id"];
    [self performSegueWithIdentifier:@"manageOffer" sender:nil];
}

- (void)copyClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSLog(@"Copy %ld",(long)button.tag);
    selectID = [[listJSON objectAtIndex:button.tag] objectForKey:@"id"];
    [dateField becomeFirstResponder];
}

- (void)duplicate
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Duplicating";
    [HUD showInView:self.view];
    
    NSString* url = [NSString stringWithFormat:@"%@Duplicate",HOST_DOMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"oid":selectID,
                                 @"goDate":goDateEN,
                                 @"goH":goH,
                                 @"goM":goM};
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"copyJSON %@",responseObject);
         HUD.textLabel.text = @"การเสนอที่นั่งถูกบันทึกแล้ว";
         HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
         [HUD dismissAfterDelay:3.0 animated:YES];
         
         [self loadList];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [HUD dismissAnimated:YES];
         [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
     }];
}

- (void)trashClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSLog(@"Trash %ld",(long)button.tag);
    selectID = [[listJSON objectAtIndex:button.tag] objectForKey:@"id"];
    
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Deleting";
    [HUD showInView:self.view];
    
    NSString* url;
    
    if ([mode isEqualToString:@"Offer"]) {
        url = [NSString stringWithFormat:@"%@cancelOffer",HOST_DOMAIN];
        HUD.textLabel.text = @"การเสนอที่นั่งถูกลบแล้ว";
    }
    
    if ([mode isEqualToString:@"Reserve"]) {
        url = [NSString stringWithFormat:@"%@cancelBooking",HOST_DOMAIN];
        HUD.textLabel.text = @"ยกเลิกการสำรองที่นั่ง";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"userEmail":sharedManager.memberID,
                                 @"oid":selectID};
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"deleteJSON %@",responseObject);
         
         HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
         [HUD dismissAfterDelay:3.0 animated:YES];
         
         [self loadList];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [HUD dismissAnimated:YES];
         [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
     }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue isKindOfClass:[CCMPopupSegue class]]){
        CCMPopupSegue *popupSegue = (CCMPopupSegue *)segue;
        popupSegue.destinationBounds = CGRectMake(0, 0, self.view.frame.size.width*0.9, self.view.frame.size.width*1.3);
        
        popupSegue.backgroundViewAlpha = 0.7;
        popupSegue.backgroundViewColor = [UIColor blackColor];
        popupSegue.dismissableByTouchingBackground = YES;
        
        ProfileOfferDetail *pod = (ProfileOfferDetail*)segue.destinationViewController;
        pod.offerID = selectID;
    }
}

- (IBAction)back:(id)sender
{
    RightMenu *rm = (RightMenu*)[sharedManager.mainRoot.childViewControllers objectAtIndex:0];
    [rm loadProfile];
    [self.navigationController popToRootViewControllerAnimated:YES];
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

