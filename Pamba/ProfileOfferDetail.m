//
//  ProfileOfferDetail.m
//  Pamba
//
//  Created by Firststep Consulting on 7/30/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "ProfileOfferDetail.h"
#import "ProfileOffer.h"
#import "ListCell.h"
#import "ReserveCell.h"
#import "OfferDetail.h"
#import "RequestDetail.h"
#import "UIImageView+WebCache.h"
#import "Web.h"

@interface ProfileOfferDetail ()

@end

@implementation ProfileOfferDetail

@synthesize offerID,mycollectionView,noresultLabel;

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
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
    [tracker set:kGAIScreenName value:@"ProfileOfferDetail"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sharedManager = [Singleton sharedManager];
    
    sharedManager.reloadOffer = YES;
    
    Tabbar *tab = (Tabbar*)sharedManager.mainTabbar;
    
    Navi *navi = (Navi*)[tab.childViewControllers objectAtIndex:0];
    homePage = (Home*)[navi.childViewControllers objectAtIndex:0];
    
    noresultLabel.hidden = YES;
    noresultLabel.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+1];
    [self shorttext:noresultLabel];
    
    refreshController = [[UIRefreshControl alloc] init];
    [refreshController addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [mycollectionView addSubview:refreshController];
    
    [self loadList];
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
    
    NSString* url = [NSString stringWithFormat:@"%@manageOffer",HOST_DOMAIN];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"userEmail":sharedManager.memberID,
                                 @"oid":offerID};
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //NSLog(@"listJSON %@",responseObject);
         
         listJSON = [[[responseObject objectForKey:@"data"] objectAtIndex:0] mutableCopy];
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
    if ([[listJSON allKeys] containsObject:@"Error"]||[[[[[listJSON objectForKey:@"JoinUser"] objectAtIndex:0] objectAtIndex:0] allKeys] containsObject:@"Error"]) {
        //ไม่มีรายการ
        rowNo = 0;
    }
    else{
        [mycollectionView reloadData];
        rowNo = [[[listJSON objectForKey:@"JoinUser"] objectAtIndex:0] count];
    }
    
    if (rowNo == 0) { noresultLabel.hidden = NO; }
    else{ noresultLabel.hidden = YES; }
    
    return rowNo;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width = (mycollectionView.frame.size.width)*0.936;
    float height = width*0.357;
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
    ListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCell" forIndexPath:indexPath];
    
    NSDictionary *cellArray = [[[listJSON objectForKey:@"JoinUser"] objectAtIndex:0] objectAtIndex:indexPath.row];
    
    [cell.userPic sd_setImageWithURL:[NSURL URLWithString:[cellArray objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"icon1024.png"]];
    
    cell.userPic.layer.cornerRadius = cell.userPic.frame.size.width/2;
    cell.userPic.layer.masksToBounds = YES;
    
    cell.nameLabel.text = [cellArray objectForKey:@"name"];
    
    cell.reviewCount.text = [NSString stringWithFormat:@"(%@ รีวิว)",[cellArray objectForKey:@"total_review"]];
    
    int star = [[cellArray objectForKey:@"rate"] intValue];
    
    UIImage *starON = [UIImage imageNamed:@"cell_star"];
    UIImage *starOFF = [UIImage imageNamed:@"cell_star_off"];
    cell.star1.image = starOFF;
    cell.star2.image = starOFF;
    cell.star3.image = starOFF;
    cell.star4.image = starOFF;
    cell.star5.image = starOFF;
    
    switch (star) {
        case 0:
            break;
            
        case 1:
            cell.star1.image = starON;
            break;
            
        case 2:
            cell.star1.image = starON;
            cell.star2.image = starON;
            break;
            
        case 3:
            cell.star1.image = starON;
            cell.star2.image = starON;
            cell.star3.image = starON;
            break;
            
        case 4:
            cell.star1.image = starON;
            cell.star2.image = starON;
            cell.star3.image = starON;
            cell.star4.image = starON;
            break;
            
        case 5:
            cell.star1.image = starON;
            cell.star2.image = starON;
            cell.star3.image = starON;
            cell.star4.image = starON;
            cell.star5.image = starON;
            break;
            
        default:
            cell.star1.image = starON;
            cell.star2.image = nil;
            cell.star3.image = starON;
            cell.star4.image = nil;
            cell.star5.image = starON;
            break;
    }
    
    [cell.chatBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.chatBtn addTarget:self action:@selector(chatClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.chatBtn.tag = indexPath.row;
    
    [cell.acceptBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.acceptBtn addTarget:self action:@selector(acceptClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.acceptBtn.tag = indexPath.row;

    
    [cell.rejectBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.rejectBtn addTarget:self action:@selector(rejectClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.rejectBtn.tag = indexPath.row;

    
    if ([[cellArray objectForKey:@"status"] isEqualToString:@"1"]) {//รอ
        cell.acceptBtn.hidden = NO;
        cell.rejectBtn.hidden = NO;
        
        [cell.acceptBtn setImage:[UIImage imageNamed:@"profile_offer_accept_on"] forState:UIControlStateNormal];
        [cell.rejectBtn setImage:[UIImage imageNamed:@"profile_offer_reject_on"] forState:UIControlStateNormal];
    }
    else if ([[cellArray objectForKey:@"status"] isEqualToString:@"2"]) {//ยอมรับ
        cell.acceptBtn.hidden = NO;
        cell.rejectBtn.hidden = YES;
        
        [cell.acceptBtn setImage:[UIImage imageNamed:@"profile_offer_accept_on"] forState:UIControlStateNormal];
        [cell.rejectBtn setImage:[UIImage imageNamed:@"profile_offer_reject_off"] forState:UIControlStateNormal];
    }
    else if ([[cellArray objectForKey:@"status"] isEqualToString:@"3"]) {//ปฏิเสธ
        cell.acceptBtn.hidden = YES;
        cell.rejectBtn.hidden = NO;
        
        [cell.acceptBtn setImage:[UIImage imageNamed:@"profile_offer_accept_off"] forState:UIControlStateNormal];
        [cell.rejectBtn setImage:[UIImage imageNamed:@"profile_offer_reject_on"] forState:UIControlStateNormal];
    }
    
    cell.nameLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+4];
    [self shorttext:cell.nameLabel];
    cell.reviewCount.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1];
    [self shorttext:cell.reviewCount];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    OfferDetail *ofd = [self.storyboard instantiateViewControllerWithIdentifier:@"OfferDetail"];
    ofd.offerID = [[listJSON objectAtIndex:indexPath.row] objectForKey:@"id"];
    [self.navigationController pushViewController:ofd animated:YES];
    */
}

- (void)chatClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSLog(@"Chat %ld",(long)button.tag);
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"โทร" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *telNumber = [NSString stringWithFormat:@"tel:%@",[[[[listJSON objectForKey:@"JoinUser"] objectAtIndex:0] objectAtIndex:button.tag] objectForKey:@"mobile"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telNumber]];
        
        // Call button tappped.
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"แชท" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        Web *web = [self.storyboard instantiateViewControllerWithIdentifier:@"Web"];
        web.webTitle = @"ติดต่อผู้ต้องการที่นั่ง";
        web.urlString = [NSString stringWithFormat:@"%@ChatWV/message?userFrom=%@&userTo=%@",HOST_DOMAIN_INDEX,sharedManager.memberID,[[[[listJSON objectForKey:@"JoinUser"] objectAtIndex:0] objectAtIndex:button.tag] objectForKey:@"user_id"]];
        [web setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:web animated:YES completion:nil];
        
        // Chat button tappped.
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"ยกเลิก" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)acceptClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSLog(@"Accept %ld",(long)button.tag);
    
    ListCell *cell = (ListCell*)[mycollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    
    cell.acceptBtn.hidden = NO;
    cell.rejectBtn.hidden = YES;
    
    [cell.acceptBtn setImage:[UIImage imageNamed:@"profile_offer_accept_on"] forState:UIControlStateNormal];
    [cell.rejectBtn setImage:[UIImage imageNamed:@"profile_offer_reject_off"] forState:UIControlStateNormal];
    
    [self manageOffer:[[[[listJSON objectForKey:@"JoinUser"] objectAtIndex:0] objectAtIndex:button.tag] objectForKey:@"accept_bt"]];
}

- (void)rejectClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSLog(@"Reject %ld",(long)button.tag);
    
    ListCell *cell = (ListCell*)[mycollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    
    cell.acceptBtn.hidden = YES;
    cell.rejectBtn.hidden = NO;
    
    [cell.acceptBtn setImage:[UIImage imageNamed:@"profile_offer_accept_off"] forState:UIControlStateNormal];
    [cell.rejectBtn setImage:[UIImage imageNamed:@"profile_offer_reject_on"] forState:UIControlStateNormal];
    
    [self manageOffer:[[[[listJSON objectForKey:@"JoinUser"] objectAtIndex:0] objectAtIndex:button.tag] objectForKey:@"refuse_bt"]];
}

- (void)manageOffer:(NSString *)url
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{};
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"Response %@",responseObject);
         
         [self loadList];
         [refreshController endRefreshing];
         [HUD dismissAnimated:YES];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [refreshController endRefreshing];
         [HUD dismissAnimated:YES];
         
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please check your internet connection and try again" preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
             
         }];
         [alertController addAction:ok];
         
         [self presentViewController:alertController animated:YES completion:nil];
         
     }];
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
