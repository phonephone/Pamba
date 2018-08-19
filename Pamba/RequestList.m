//
//  RequestList.m
//  Pamba
//
//  Created by Firststep Consulting on 7/8/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "RequestList.h"
#import "RequestDetail.h"
#import "ListCell.h"
#import "UIImageView+WebCache.h"

@interface RequestList ()

@end

@implementation RequestList

@synthesize mycollectionView;

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    startScrollViewYOffset = homePage.toolBar.frame.origin.y;
    
    [mycollectionView.collectionViewLayout collectionViewContentSize];
    mycollectionView.contentInset = UIEdgeInsetsMake(homePage.toolBar.frame.size.height, 0.0, 0.0, 0.0);
    [mycollectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"RequestList"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    if (sharedManager.reloadRequest == YES) {
        [self loadList];
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sharedManager = [Singleton sharedManager];
    
    Tabbar *tab = (Tabbar*)sharedManager.mainTabbar;
    Navi *navi = (Navi*)[tab.childViewControllers objectAtIndex:0];
    homePage = (Home*)[navi.childViewControllers objectAtIndex:0];
    
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
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString* url;
    NSDictionary *parameters;
    if ([sharedManager.sortMode isEqualToString:@"nearby"]) {
        url = [NSString stringWithFormat:@"%@searchRequestNearMe",HOST_DOMAIN];
        parameters = @{@"lat":sharedManager.latitude,
                       @"lng":sharedManager.longitude
                       };
    }
    else{
        url = [NSString stringWithFormat:@"%@RequestList",HOST_DOMAIN];
        parameters = @{};
    }
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"listJSON %@",responseObject);
         listJSON = [[responseObject objectForKey:@"data"] mutableCopy];
         
         [mycollectionView reloadData];
         
         [refreshController endRefreshing];
         [HUD dismissAnimated:YES];
         
         sharedManager.reloadRequest = NO;
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
    return [listJSON count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width = (mycollectionView.frame.size.width)*0.936;
    float height = width*0.542;
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
    
    NSDictionary *cellArray = [listJSON objectAtIndex:indexPath.row];
    
    cell.userPic.layer.cornerRadius = cell.userPic.frame.size.width/2;
    cell.userPic.layer.masksToBounds = YES;
    
    [cell.userPic sd_setImageWithURL:[NSURL URLWithString:[cellArray objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"icon1024.png"]];
    
    [cell.moreBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.moreBtn addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.moreBtn.tag = indexPath.row;
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@",[cellArray objectForKey:@"forename"],[cellArray objectForKey:@"surname"]];
    
    cell.startLabel.text = [cellArray objectForKey:@"From"];
    cell.endLabel.text = [cellArray objectForKey:@"To"];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@ เวลา %@:%@ น.",[cellArray objectForKey:@"goDate"],[cellArray objectForKey:@"goH"],[cellArray objectForKey:@"goM"]];
    
    cell.reviewCount.text = [NSString stringWithFormat:@"(%@ รีวิว)",[[[cellArray objectForKey:@"rate"]objectAtIndex:0] objectForKey:@"total_review"]];
    
    int star = [[[[cellArray objectForKey:@"rate"] objectAtIndex:0] objectForKey:@"rate"] intValue];
    
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
    
    cell.nameLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+4];
    [self shorttext:cell.nameLabel];
    cell.reviewCount.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1];
    [self shorttext:cell.reviewCount];
    cell.startLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1];
    [self shorttext:cell.startLabel];
    cell.endLabel.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+1];
    [self shorttext:cell.endLabel];
    cell.dateLabel.font = [UIFont fontWithName:@"Kanit-Light" size:sharedManager.fontSize-3];
    [self shorttext:cell.dateLabel];
    //cell.nearLabel.font = [UIFont fontWithName:@"Kanit-Light" size:sharedManager.fontSize-3];
    //[self shorttext:cell.nearLabel];
    //cell.percentLabel.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize-2];
    //[self shorttext:cell.percentLabel];
    
    return cell;
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RequestDetail *ofd = [self.storyboard instantiateViewControllerWithIdentifier:@"RequestDetail"];
    ofd.requestID = [[listJSON objectAtIndex:indexPath.row] objectForKey:@"id"];
    [self.navigationController pushViewController:ofd animated:YES];
    //NSLog(@"Click %d",indexPath.row);
}

- (void)moreClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self collectionView:mycollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:1]];
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

