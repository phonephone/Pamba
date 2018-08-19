//
//  RequestDetail.m
//  Pamba
//
//  Created by Firststep Consulting on 7/11/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "RequestDetail.h"
#import "MainCell.h"
#import "NoCell.h"
#import "DetailCell.h"
#import "RightMenu.h"
#import "UIImageView+WebCache.h"
#import "DriverProfile.h"
#import "Web.h"

@interface RequestDetail ()

@end

@implementation RequestDetail

@synthesize requestID,rightBtn,bgView,headerView,headerTitle,myTable,blueBtn,orangeBtn,backBtn;

- (void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = YES;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"RequestDetail"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBarController.tabBar.hidden = YES;
    
    sharedManager = [Singleton sharedManager];
    
    [backBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    Tabbar *tab = (Tabbar*)sharedManager.mainTabbar;
    Navi *navi = (Navi*)[tab.childViewControllers objectAtIndex:0];
    homePage = (Home*)[navi.childViewControllers objectAtIndex:0];
    
    //NSLog(@"What %@",[tab.childViewControllers objectAtIndex:0]);
    
    headerTitle.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+4];
    [self shorttext:headerTitle];
    
    [orangeBtn.titleLabel setFont:[UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+6]];
    
    owner = NO;
    
    [self loadList];
}

- (void)loadList
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    NSLog(@"reqid %@",requestID);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@viewRequest",HOST_DOMAIN];
    NSDictionary *parameters = @{@"oid":requestID,};
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
        return 2;
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
    
    DetailCell *cell2 = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    
    NSDictionary *cellArray = [listJSON objectAtIndex:0];
    
    cell1.contactBtn.hidden = NO;
    cell1.detailBtn.hidden = NO;
    
    if ([[cellArray objectForKey:@"user"] isEqualToString:sharedManager.memberID]) {
        owner = YES;
        [orangeBtn setTitle:@"แก้ไขการสำรองที่นั่ง" forState:UIControlStateNormal];
        [orangeBtn setBackgroundColor:sharedManager.btnThemeColor];
        orangeBtn.enabled = YES;
        
        cell1.contactBtn.hidden = YES;
        cell1.detailBtn.hidden = YES;
        
        NSLog(@"เจ้าของทริป");
    }
    
    if (indexPath.row == 0) { //Main
        
        cell1.userPic.image = [UIImage imageWithCIImage:[CIImage imageWithContentsOfURL:[NSURL URLWithString:[cellArray objectForKey:@"userPic"]]]];
        //[cell1.userPic sd_setImageWithURL:[NSURL URLWithString:[cellArray objectForKey:@"userPic"]] placeholderImage:[UIImage imageNamed:@"icon1024.png"]];
        cell1.userPic.layer.cornerRadius = cell1.userPic.frame.size.width/2;
        cell1.userPic.layer.masksToBounds = YES;
        
        [cell1.contactBtn addTarget:self action:@selector(contactClick:) forControlEvents:UIControlEventTouchUpInside];
        cell1.contactBtn.tag = indexPath.row;
        
        [cell1.detailBtn addTarget:self action:@selector(detailClick:) forControlEvents:UIControlEventTouchUpInside];
        cell1.detailBtn.tag = indexPath.row;
        
        cell1.nameLabel.text = [cellArray objectForKey:@"name"];
        cell1.startLabel.text = [cellArray objectForKey:@"From"];
        cell1.endLabel.text = [cellArray objectForKey:@"To"];
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
        
        cell1.seatPic.image = nil;
        cell1.seatLabel.text = @"";
    
        cell = cell1;
    }
    
    if (indexPath.row == 1) {
        
        cell2.detailHeadLabel.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+1];
        [self shorttext:cell2.detailHeadLabel];
        
        cell2.detailLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize];
        NSString *routeDetail = [cellArray objectForKey:@"remark"];
        if ([routeDetail isEqualToString:@""])
        {
            cell2.detailLabel.text = @"-";
        }
        else{
            NSAttributedString* attrText = [[NSAttributedString alloc] initWithData:[routeDetail dataUsingEncoding:NSUTF8StringEncoding]
                                                                            options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                      NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
            [cell2.detailLabel setText:[attrText string]];
            [self shorttext:cell2.detailLabel];
        }
        cell = cell2;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)contactClick:(id)sender {
    NSLog(@"Contact");
    [self performSelector: @selector(orangeClick:) withObject:self afterDelay: 0.0];
}

- (IBAction)detailClick:(id)sender {
    NSLog(@"Detail");
    DriverProfile *drp = [self.storyboard instantiateViewControllerWithIdentifier:@"DriverProfile"];
    drp.userType = @"passenger";
    drp.driverID = [[listJSON objectAtIndex:0] objectForKey:@"user"];
    [self.navigationController pushViewController:drp animated:YES];
}

- (IBAction)orangeClick:(id)sender {
    NSLog(@"Orange");
    
    if (owner == YES) {
        NSLog(@"แก้ดิ");
        [self alertTitle:@"Coming soon" detail:@"ขออภัยในความไม่สะดวก"];
    }
    else
    {
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
            web.webTitle = @"ติดต่อผู้ต้องการที่นั่ง";
            web.urlString = [NSString stringWithFormat:@"%@ChatWV/message?userFrom=%@&userTo=%@",HOST_DOMAIN_INDEX,sharedManager.memberID,[[listJSON objectAtIndex:0] objectForKey:@"user"]];
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
