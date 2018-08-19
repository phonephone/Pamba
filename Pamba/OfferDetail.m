//
//  OfferDetail.m
//  Pamba
//
//  Created by Firststep Consulting on 7/9/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "OfferDetail.h"
#import "OfferMap.h"
#import "MainCell.h"
#import "NoCell.h"
#import "DetailCell.h"
#import "RightMenu.h"
#import "UIImageView+WebCache.h"
#import "DriverProfile.h"
#import "Web.h"
#import "EditTrip.h"

@interface OfferDetail ()

@end

@implementation OfferDetail

@synthesize offerID,rightBtn,bgView,headerView,headerTitle,myTable,blueBtn,orangeBtn,backBtn;

- (void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = YES;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"OfferDetail"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self loadList];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBarController.tabBar.hidden = YES;
    
    [backBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    sharedManager = [Singleton sharedManager];
    
    Tabbar *tab = (Tabbar*)sharedManager.mainTabbar;
    Navi *navi = (Navi*)[tab.childViewControllers objectAtIndex:0];
    homePage = (Home*)[navi.childViewControllers objectAtIndex:0];
    
    //NSLog(@"What %@",[tab.childViewControllers objectAtIndex:0]);
    
    headerTitle.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+4];
    [self shorttext:headerTitle];
    
    [orangeBtn.titleLabel setFont:[UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+6]];
    
    owner = NO;
}

- (void)loadList
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    NSLog(@"offid %@",offerID);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@viewOffer",HOST_DOMAIN];
    NSDictionary *parameters = @{@"oid":offerID,
                                 @"userEmail":sharedManager.memberID};
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //NSLog(@"listJSON %@",responseObject);
         listJSON = [[responseObject objectForKey:@"data"] mutableCopy];
         
         [HUD dismissAnimated:YES];
         
         [myTable reloadData];
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [HUD dismissAnimated:YES];
         
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"เกิดข้อผิดพลาด" message:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง" preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
             
             [self loadList];
         }];
         [alertController addAction:ok];
         
         [self presentViewController:alertController animated:YES completion:nil];
         
     }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (listJSON.count != 0) {
        return 3;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //float rowHeight = myTable.frame.size.height/5;
    
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    MainCell *cell1 = (MainCell *)[tableView dequeueReusableCellWithIdentifier:@"MainCell"];
    
    NoCell *cell2 = (NoCell *)[tableView dequeueReusableCellWithIdentifier:@"NoCell"];
    
    DetailCell *cell3 = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    
    NSDictionary *cellArray = [listJSON objectAtIndex:0];
    
    cell1.contactBtn.hidden = NO;
    cell1.detailBtn.hidden = NO;
    
    if ([[cellArray objectForKey:@"user"] isEqualToString:sharedManager.memberID]) {
        owner = YES;
        [orangeBtn setTitle:@"แก้ไขการเสนอที่นั่ง" forState:UIControlStateNormal];
        [orangeBtn setBackgroundColor:sharedManager.btnThemeColor];
        orangeBtn.enabled = YES;
        
        cell1.contactBtn.hidden = YES;
        cell1.detailBtn.hidden = YES;
        
        NSLog(@"เจ้าของทริป");
    }
    else if ([[cellArray objectForKey:@"join_status"] intValue] == 1) {
        [orangeBtn setTitle:@"จองที่นั่งแล้ว" forState:UIControlStateNormal];
        [orangeBtn setBackgroundColor:[UIColor grayColor]];
        orangeBtn.enabled = NO;
        NSLog(@"จองแล้ว");
    }
    else if ([[cellArray objectForKey:@"now_seat"] intValue] == 0) {
        [orangeBtn setTitle:@"ที่นั่งเต็ม" forState:UIControlStateNormal];
        [orangeBtn setBackgroundColor:[UIColor grayColor]];
        orangeBtn.enabled = NO;
        NSLog(@"ที่นั่งเต็ม");
    }
    else{
        [orangeBtn setTitle:@"จองที่นั่ง" forState:UIControlStateNormal];
        [orangeBtn setBackgroundColor:sharedManager.btnThemeColor];
        orangeBtn.enabled = YES;
        NSLog(@"ยังไม่จอง");
    }
    
    if (indexPath.row == 0) { //Main
        
        cell1.userPic.image = [UIImage imageWithCIImage:[CIImage imageWithContentsOfURL:[NSURL URLWithString:[cellArray objectForKey:@"userPic"]]]];
        //[cell1.userPic sd_setImageWithURL:[NSURL URLWithString:[cellArray objectForKey:@"userPic"]] placeholderImage:[UIImage imageNamed:@"icon1024.png"]];
        cell1.userPic.layer.cornerRadius = cell1.userPic.frame.size.width/2;
        cell1.userPic.layer.masksToBounds = YES;
        
        cell1.carType.image = [UIImage imageNamed:[NSString stringWithFormat:@"car%@",[cellArray objectForKey:@"type"]]];
        
        //[cell1.contactBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell1.contactBtn addTarget:self action:@selector(contactClick:) forControlEvents:UIControlEventTouchUpInside];
        cell1.contactBtn.tag = indexPath.row;
        
        //[cell1.detailBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell1.detailBtn addTarget:self action:@selector(detailClick:) forControlEvents:UIControlEventTouchUpInside];
        cell1.detailBtn.tag = indexPath.row;
        
        cell1.nameLabel.text = [cellArray objectForKey:@"name"];
        cell1.startLabel.text = [cellArray objectForKey:@"From"];
        cell1.endLabel.text = [cellArray objectForKey:@"To"];
        cell1.priceLabel.text = [cellArray objectForKey:@"price"];
        cell1.dateLabel.text = [NSString stringWithFormat:@"วันเดินทาง\n%@",[cellArray objectForKey:@"goDate"]];
        cell1.timeLabel.text = [NSString stringWithFormat:@"%@:%@ น.",[cellArray objectForKey:@"goH"],[cellArray objectForKey:@"goM"]];
        
        cell1.distanceLabel.text = [cellArray objectForKey:@"distance"];
        cell1.seatLabel.text = [NSString stringWithFormat:@"ว่าง %@ ที่นั่ง",[cellArray objectForKey:@"now_seat"]];
        
        cell1.reviewCount.text = [NSString stringWithFormat:@"(%@ รีวิว)",[[[cellArray objectForKey:@"rate"]objectAtIndex:0] objectForKey:@"total_review"]];
        
        int star = [[[[cellArray objectForKey:@"rate"] objectAtIndex:0] objectForKey:@"rate"] intValue];
        
        UIImage *starON = [UIImage imageNamed:@"cell_star"];
        UIImage *starOFF = [UIImage imageNamed:@"cell_star_off"];
        cell1.star1.image = starOFF;
        cell1.star2.image = starOFF;
        cell1.star3.image = starOFF;
        cell1.star4.image = starOFF;
        cell1.star5.image = starOFF;
        
        switch (star) {
                case 0:
                break;
                
                case 1:
                cell1.star1.image = starON;
                break;
                
                case 2:
                cell1.star1.image = starON;
                cell1.star2.image = starON;
                break;
                
                case 3:
                cell1.star1.image = starON;
                cell1.star2.image = starON;
                cell1.star3.image = starON;
                break;
                
                case 4:
                cell1.star1.image = starON;
                cell1.star2.image = starON;
                cell1.star3.image = starON;
                cell1.star4.image = starON;
                break;
                
                case 5:
                cell1.star1.image = starON;
                cell1.star2.image = starON;
                cell1.star3.image = starON;
                cell1.star4.image = starON;
                cell1.star5.image = starON;
                break;
                
            default:
                cell1.star1.image = starON;
                cell1.star2.image = nil;
                cell1.star3.image = starON;
                cell1.star4.image = nil;
                cell1.star5.image = starON;
                break;
        }
        
        cell1.nameLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+4];
        [self shorttext:cell1.nameLabel];
        cell1.reviewCount.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1];
        [self shorttext:cell1.reviewCount];
        cell1.startLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1];
        [self shorttext:cell1.startLabel];
        cell1.endLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1];
        [self shorttext:cell1.endLabel];
        cell1.priceLabel.font = [UIFont fontWithName:@"Kanit-Bold" size:sharedManager.fontSize+21];
        [self shorttext:cell1.priceLabel];
        cell1.bahtLabel.font = [UIFont fontWithName:@"Kanit-Light" size:sharedManager.fontSize+4];
        [self shorttext:cell1.bahtLabel];
        
        cell1.dateLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize-2];
        [self shorttext:cell1.dateLabel];
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.alignment = NSTextAlignmentCenter;
        paragraph.lineSpacing = 1.0f;
        paragraph.lineHeightMultiple = 0.7;     // Reduce this value !!!
        NSMutableAttributedString* attrText = [[NSMutableAttributedString alloc] initWithString:cell1.dateLabel.text];
        [attrText addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, cell1.dateLabel.text.length)];
        [cell1.dateLabel setAttributedText:attrText];
        cell1.timeLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize-2];
        [self shorttext:cell1.timeLabel];
        cell1.distanceLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize-2];
        [self shorttext:cell1.distanceLabel];
        cell1.seatLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize-2];
        [self shorttext:cell1.seatLabel];
        
        cell = cell1;
    }
 
    if (indexPath.row == 1) { //No
        
        cell2.noPic2.image = nil;
        cell2.noLabel2.text = @"";
        cell2.noPic3.image = nil;
        cell2.noLabel3.text = @"";
        cell2.noPic4.image = nil;
        cell2.noLabel4.text = @"";
        cell2.noPic5.image = nil;
        cell2.noLabel5.text = @"";

        NSArray *array = [cellArray objectForKey:@"option"];
        int x = 501;
        
        if ([array containsObject: @"pet"])
        {
            UIImageView *img = (UIImageView *)[cell2.contentView viewWithTag:x];
            UILabel *label = (UILabel *)[cell2.contentView viewWithTag:x+10];
            img.image = [UIImage imageNamed:@"no-pet"];
            label.text = @"ห้ามสัตว์เลี้ยงขึ้น";
            img.hidden = NO;
            label.hidden = NO;
            x++;
        }
        if ([array containsObject: @"music"])
        {
            UIImageView *img = (UIImageView *)[cell2.contentView viewWithTag:x];
            UILabel *label = (UILabel *)[cell2.contentView viewWithTag:x+10];
            img.image = [UIImage imageNamed:@"no-music"];
            label.text = @"ไม่เปิดเพลง";
            img.hidden = NO;
            label.hidden = NO;
            x++;
        }
        if ([array containsObject: @"food"])
        {
            UIImageView *img = (UIImageView *)[cell2.contentView viewWithTag:x];
            UILabel *label = (UILabel *)[cell2.contentView viewWithTag:x+10];
            img.image = [UIImage imageNamed:@"no-food"];
            label.text = @"ห้ามทานอาหาร";
            img.hidden = NO;
            label.hidden = NO;
            x++;
        }
        if ([array containsObject: @"smoking"])
        {
            UIImageView *img = (UIImageView *)[cell2.contentView viewWithTag:x];
            UILabel *label = (UILabel *)[cell2.contentView viewWithTag:x+10];
            img.image = [UIImage imageNamed:@"no-smoke"];
            label.text = @"ห้ามสูบบุหรี่";
            img.hidden = NO;
            label.hidden = NO;
            x++;
        }
        
        NSString *bagSize = [cellArray objectForKey:@"luggage"];
        if([bagSize isEqualToString:@"เล็ก"])
        {
            UIImageView *img = (UIImageView *)[cell2.contentView viewWithTag:x];
            UILabel *label = (UILabel *)[cell2.contentView viewWithTag:x+10];
            img.image = [UIImage imageNamed:@"bag1"];
            label.text = @"ขนาดเล็ก";
            img.hidden = NO;
            label.hidden = NO;
        }
        else if([bagSize isEqualToString:@"กลาง"])
        {
            UIImageView *img = (UIImageView *)[cell2.contentView viewWithTag:x];
            UILabel *label = (UILabel *)[cell2.contentView viewWithTag:x+10];
            img.image = [UIImage imageNamed:@"bag2"];
            label.text = @"ขนาดกลาง";
            img.hidden = NO;
            label.hidden = NO;
        }
        else if([bagSize isEqualToString:@"ใหญ่"])
        {
            UIImageView *img = (UIImageView *)[cell2.contentView viewWithTag:x];
            UILabel *label = (UILabel *)[cell2.contentView viewWithTag:x+10];
            img.image = [UIImage imageNamed:@"bag3"];
            label.text = @"ขนาดใหญ่";
            img.hidden = NO;
            label.hidden = NO;
        }

        NSString* detect = @"ข้อกำหนดของ";
        cell2.nameLabel.text = [NSString stringWithFormat:@"%@ %@",detect,[cellArray objectForKey:@"name"]];
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:cell2.nameLabel.text];
        [attrString setAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+3] } range:NSMakeRange(0, cell2.nameLabel.text.length)];
        [attrString setAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1] } range:NSMakeRange(0, detect.length)];
        [attrString addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:-0.5] range:NSMakeRange(0, cell2.nameLabel.text.length)];
        [cell2.nameLabel setAttributedText:attrString];
        
        //cell2.nameLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+4];
        //[self shorttext:cell2.nameLabel];
        
        cell2.noLabel1.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize-3];
        [self shorttext:cell2.noLabel1];
        cell2.noLabel2.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize-3];
        [self shorttext:cell2.noLabel2];
        cell2.noLabel3.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize-3];
        [self shorttext:cell2.noLabel3];
        cell2.noLabel4.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize-3];
        [self shorttext:cell2.noLabel4];
        cell2.noLabel5.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize-3];
        [self shorttext:cell2.noLabel5];
        
        cell = cell2;
    }
 
    if (indexPath.row == 2) {
        
        cell3.detailHeadLabel.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+1];
        [self shorttext:cell3.detailHeadLabel];
        
        cell3.detailLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
        NSString *routeDetail = [cellArray objectForKey:@"remark"];
        if ([routeDetail isEqualToString:@""])
        {
            cell3.detailLabel.text = @"-";
        }
        else{
            NSAttributedString* attrText = [[NSAttributedString alloc] initWithData:[routeDetail dataUsingEncoding:NSUTF8StringEncoding]
                                                                            options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                      NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
            [cell3.detailLabel setText:[attrText string]];
            [self shorttext:cell3.detailLabel];
        }
        
        cell3.pickHeadLabel.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+1];
        [self shorttext:cell3.pickHeadLabel];
        
        cell3.pickLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
        
        NSArray *waypointArray = [cellArray objectForKey:@"way_point"];
        NSString *waypoint = @"";
        if ([[waypointArray objectAtIndex:0] isEqualToString:@""]) {
            cell3.pickLabel.text = @"-";
        }
        else{
            for(int i = 0; i < [waypointArray count]; i++)
            {
                NSArray *subStrings = [[waypointArray objectAtIndex:i] componentsSeparatedByString:@","];
                NSString *firstString = [subStrings objectAtIndex:0];
                if (![firstString isEqualToString:@""]) {
                    waypoint = [NSString stringWithFormat:@"%@%d) %@\n",waypoint,i+1,firstString];
                }
            }
            cell3.pickLabel.text = waypoint;
        }
        [self shorttext:cell3.pickLabel];
        
        cell3.extimeLabel.text = [NSString stringWithFormat:@"โพสต์เมื่อ %@\nการเจาะจงเวลาเดินทาง ± %@ (นาที)",[cellArray objectForKey:@"cdate"],[cellArray objectForKey:@"exTime"]];
        cell3.extimeLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize-4];
        [self shorttext:cell3.extimeLabel];
        
        cell = cell3;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)contactClick:(id)sender {
    NSLog(@"Contact");
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"โทร" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *telNumber = [NSString stringWithFormat:@"tel:%@",[[listJSON objectAtIndex:0] objectForKey:@"mobile"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telNumber]];
        
        // Call button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"แชท" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        Web *web = [self.storyboard instantiateViewControllerWithIdentifier:@"Web"];
        web.webTitle = @"ติดต่อผู้เสนอที่นั่ง";
        web.urlString = [NSString stringWithFormat:@"%@ChatWV/message?userFrom=%@&userTo=%@",HOST_DOMAIN_INDEX,sharedManager.memberID,[[listJSON objectAtIndex:0] objectForKey:@"user"]];
        NSLog(@"%@",web.urlString);
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

- (IBAction)detailClick:(id)sender {
    NSLog(@"Detail");
    //UIButton *button = (UIButton *)sender;
    DriverProfile *drp = [self.storyboard instantiateViewControllerWithIdentifier:@"DriverProfile"];
    drp.userType = @"driver";
    drp.driverID = [[listJSON objectAtIndex:0] objectForKey:@"user"];
    [self.navigationController pushViewController:drp animated:YES];
}

- (IBAction)blueClick:(id)sender {
    NSLog(@"Blue");
    OfferMap *ofm = [self.storyboard instantiateViewControllerWithIdentifier:@"OfferMap"];
    ofm.offerID = offerID;
    [self.navigationController pushViewController:ofm animated:YES];
}

- (IBAction)orangeClick:(id)sender {
    if (owner == YES) {
        NSLog(@"แก้ดิ");
        
        NSDictionary *cellArray = [listJSON objectAtIndex:0];
        
        EditTrip *ofe = [self.storyboard instantiateViewControllerWithIdentifier:@"EditTrip"];
        ofe.offerID = offerID;
        ofe.goDate = [cellArray objectForKey:@"goDate"];
        ofe.goH = [cellArray objectForKey:@"goH"];
        ofe.goM = [cellArray objectForKey:@"goM"];
        ofe.price = [cellArray objectForKey:@"price"];
        ofe.seats = [cellArray objectForKey:@"now_seat"];
        ofe.remark = [cellArray objectForKey:@"remark"];
        [self.navigationController pushViewController:ofe animated:YES];
    }
    else
    {
        JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        HUD.textLabel.text = @"Booking";
        [HUD showInView:self.view];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString* url = [NSString stringWithFormat:@"%@bookingSeat",HOST_DOMAIN];
        NSDictionary *parameters = @{@"oid":offerID,
                                     @"user":sharedManager.memberID
                                     };
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"detailJSON %@",responseObject);
             HUD.textLabel.text = [[[[responseObject objectForKey:@"data"] objectAtIndex:0] objectForKey:@"status"] objectAtIndex:1];
             HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
             [HUD dismissAfterDelay:3.0 animated:YES];
             
             [orangeBtn setTitle:@"จองที่นั่งแล้ว" forState:UIControlStateNormal];
             [orangeBtn setBackgroundColor:[UIColor grayColor]];
             orangeBtn.enabled = NO;
             
             sharedManager.reloadOffer = YES;
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error %@",error);
             [HUD dismissAnimated:YES];
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"เกิดข้อผิดพลาด" message:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง" preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                 
                 [self loadList];
             }];
             [alertController addAction:ok];
             
             [self presentViewController:alertController animated:YES completion:nil];
             
         }];
    }
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

- (IBAction)showRightMenuPressed:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
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

