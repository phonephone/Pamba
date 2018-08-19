//
//  Search.m
//  Pamba
//
//  Created by Firststep Consulting on 7/18/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "Search.h"
#import "OfferDetail.h"
#import "ListCell.h"
#import "SearchCell.h"
#import "NotFoundCell.h"
#import "UIImageView+WebCache.h"

@interface Search () <GMSAutocompleteViewControllerDelegate>

@end

@implementation Search
{
    GMSPlacesClient *_placesClient;
    GMSAutocompleteResultsViewController *_resultsViewController;
}

@synthesize bgView,headerView,headerTitle,mycollectionView;

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
    self.tabBarController.tabBar.hidden = NO;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Search"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sharedManager = [Singleton sharedManager];
    
    Tabbar *tab = (Tabbar*)sharedManager.mainTabbar;
    Navi *navi = (Navi*)[tab.childViewControllers objectAtIndex:0];
    homePage = (Home*)[navi.childViewControllers objectAtIndex:0];
    
    _placesClient = [GMSPlacesClient sharedClient];
    
    fromID = @"";
    toID = @"";
    notFound = NO;
    
    [headerTitle setAttributedText:[self shorttext:headerTitle.text withFont:[UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+4]]];
    
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
    
    [df setDateFormat:@"yyyy-MM-dd"];
    //goDate = [df stringFromDate:[NSDate date]];
    goDate = @"";
}

-(void)viewDidAppear:(BOOL)animated
{
    SearchCell *searchCell = (SearchCell*)[mycollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
     [self addbottomBorder:searchCell.fromField withColor:[UIColor colorWithRed:75.0/255 green:195.0/255 blue:248.0/255 alpha:1]];
     [self addbottomBorder:searchCell.toField withColor:nil];
     [self addbottomBorder:searchCell.dateField withColor:nil];
}

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    if (notFound == YES) {
        return 2;
    }
    else
    {
        return [searchJSON count]+1;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width;
    float height;
    CGSize itemSize;
    
    if (indexPath.row == 0) {//Search
        width = (mycollectionView.frame.size.width)*0.936;
        height = width*(0.85);
        itemSize = CGSizeMake(width,height);
    }
    else {
        if (notFound == YES) {
            width = (mycollectionView.frame.size.width)*0.936;
            height = width*0.3;
            itemSize = CGSizeMake(width,height);
        }
        else{
            width = (mycollectionView.frame.size.width)*0.936;
            height = width*0.542;
            itemSize = CGSizeMake(width,height);
        }
    }
    
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
    UICollectionViewCell *mainCell = [[UICollectionViewCell alloc] init];
    
    SearchCell *cell0 = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchCell" forIndexPath:indexPath];
    
    NotFoundCell *noCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NotFoundCell" forIndexPath:indexPath];
    
    ListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0){//Search
        
        cell0.fromField.tag = 101;
        cell0.toField.tag = 102;
        
        [cell0.targetBtn addTarget:self action:@selector(locationClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell0.swapBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell0.swapBtn.titleLabel setAttributedText:[self shorttext:cell0.swapBtn.titleLabel.text withFont:[UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+4]]];
        [cell0.swapBtn addTarget:self action:@selector(swapClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell0.dateLabel setAttributedText:[self shorttext:cell0.dateLabel.text withFont:nil]];
        
        cell0.dateField.inputView = dayPicker;
        [df setDateFormat:@"dd MMM yyyy"];
        //cell0.dateField.text = [df stringFromDate:[NSDate date]];
        cell0.dateField.text = @"ไม่กำหนดวัน";
        cell0.dateField.tag = 999;
        
        [cell0.searchBtn addTarget:self action:@selector(searchClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //[self addbottomBorder:cell0.fromField withColor:[UIColor colorWithRed:75.0/255 green:195.0/255 blue:248.0/255 alpha:1]];
        //[self addbottomBorder:cell0.toField withColor:nil];
        //[self addbottomBorder:cell0.dateField withColor:nil];
        
        mainCell = cell0;
    }
    
    if (indexPath.row > 0)
    {
        if (notFound == YES) {
            noCell.notLabel.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+4];
            [self shorttext:noCell.notLabel];
            [noCell.notBtn addTarget:self action:@selector(requestClick:) forControlEvents:UIControlEventTouchUpInside];
            
            mainCell = noCell;
        }
        else{
            NSDictionary *cellArray = [searchJSON objectAtIndex:indexPath.row-1];
            
            [cell.userPic sd_setImageWithURL:[NSURL URLWithString:[cellArray objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"icon1024.png"]];
            
            cell.carType.image = [UIImage imageNamed:[NSString stringWithFormat:@"car%@",[cellArray objectForKey:@"type"]]];
            
            cell.userPic.layer.cornerRadius = cell.userPic.frame.size.width/2;
            cell.userPic.layer.masksToBounds = YES;
            
            /*
            [cell.moreBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [cell.moreBtn addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.moreBtn.tag = indexPath.row;
            */
             
            cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@",[cellArray objectForKey:@"forename"],[cellArray objectForKey:@"surname"]];
            
            cell.startLabel.text = [cellArray objectForKey:@"From"];
            cell.endLabel.text = [cellArray objectForKey:@"To"];
            cell.priceLabel.text = [cellArray objectForKey:@"price"];
            cell.dateLabel.text = [NSString stringWithFormat:@"%@ เวลา %@:%@ น.",[cellArray objectForKey:@"goDate"],[cellArray objectForKey:@"goH"],[cellArray objectForKey:@"goM"]];
            cell.percentLabel.text = [NSString stringWithFormat:@"%d%%",[[cellArray objectForKey:@"avg"] intValue]];
            cell.seatLabel.text = [NSString stringWithFormat:@"%@ ที่นั่ง",[cellArray objectForKey:@"now_seat"]];
            
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
            cell.priceLabel.font = [UIFont fontWithName:@"Kanit-Bold" size:sharedManager.fontSize+21];
            [self shorttext:cell.priceLabel];
            cell.bahtLabel.font = [UIFont fontWithName:@"Kanit-Light" size:sharedManager.fontSize+4];
            [self shorttext:cell.bahtLabel];
            cell.dateLabel.font = [UIFont fontWithName:@"Kanit-Light" size:sharedManager.fontSize-3];
            [self shorttext:cell.dateLabel];
            cell.nearLabel.font = [UIFont fontWithName:@"Kanit-Light" size:sharedManager.fontSize-3];
            [self shorttext:cell.nearLabel];
            cell.percentLabel.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize-2];
            [self shorttext:cell.percentLabel];
            cell.seatLabel.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize-2];
            [self shorttext:cell.seatLabel];
            
            mainCell = cell;
        }
    }
    
    return mainCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){//Search
        
    }
    else{
        if (notFound == YES) {
        }
        else{
            OfferDetail *ofd = [self.storyboard instantiateViewControllerWithIdentifier:@"OfferDetail"];
            ofd.offerID = [[searchJSON objectAtIndex:indexPath.row-1] objectForKey:@"id"];
            [self.navigationController pushViewController:ofd animated:YES];
        }
    }
    
    //[self.menuContainerViewController.centerViewController pushViewController:ofd animated:YES];
    //NSLog(@"Click %d",indexPath.row);
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
    
    if (textField.tag == 999) {
        SearchCell *searchCell = (SearchCell*)[mycollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        [df setDateFormat:@"dd MMM yyyy"];
        searchCell.dateField.text = [df stringFromDate:dayPicker.date];
        
        [df setDateFormat:@"yyyy-MM-dd"];
        goDate = [df stringFromDate:dayPicker.date];
    }
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
    
    SearchCell *searchCell = (SearchCell*)[mycollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (nowEdit == 101) {
        searchCell.fromField.text = place.name;
        fromID = place.placeID;
    }
    if (nowEdit == 102) {
        searchCell.toField.text = place.name;
        toID = place.placeID;
    }
    
    [searchJSON removeAllObjects];
    notFound = NO;
    [mycollectionView reloadData];
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

- (void)moreClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self collectionView:mycollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:1]];
}

- (void)datePickerValueChanged:(UIDatePicker *)datePicker
{
    SearchCell *searchCell = (SearchCell*)[mycollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [df setDateFormat:@"dd MMM yyyy"];
    searchCell.dateField.text = [df stringFromDate:datePicker.date];
    
    [df setDateFormat:@"yyyy-MM-dd"];
    goDate = [df stringFromDate:datePicker.date];
}

- (UITextField*)addbottomBorder:(UITextField*)textField withColor:(UIColor*)color
{
    SearchCell *searchCell = (SearchCell*)[mycollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    textField.delegate = self;
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, textField.frame.size.height - 1, textField.frame.size.width, 1.0f);
    
    if (color == nil) {
        bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1].CGColor;
    }
    else{
        bottomBorder.backgroundColor = color.CGColor;
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,searchCell.targetBtn.frame.size.width, 20)];
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
    SearchCell *searchCell = (SearchCell*)[mycollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
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
        searchCell.fromField.text = @"ไม่พบชื่อสถานที่ปัจจุบัน";
        //toField.text = @"";
        
        if (placeLikelihoodList != nil) {
            GMSPlace *place = [[[placeLikelihoodList likelihoods] firstObject] place];
            if (place != nil) {
                fromID = place.placeID;
                searchCell.fromField.text = place.name;
                //toField.text = [[place.formattedAddress componentsSeparatedByString:@", "] componentsJoinedByString:@"\n"];
                [HUD dismissAnimated:YES];
            }
        }
    }];
}

- (IBAction)swapClick:(id)sender
{
    SearchCell *searchCell = (SearchCell*)[mycollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    //UIButton *button = (UIButton *)sender;
    NSString *fromText = searchCell.fromField.text;
    NSString *toText = searchCell.toField.text;
    NSString *beforeFromID = fromID;
    NSString *beforeToID = toID;
    
    searchCell.fromField.text = toText;
    searchCell.toField.text = fromText;
    fromID = beforeToID;
    toID = beforeFromID;
}

- (IBAction)searchClick:(id)sender
{
    SearchCell *searchCell = (SearchCell*)[mycollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if ([searchCell.fromField.text isEqualToString:@""]||[searchCell.toField.text isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ยังไม่ได้กำหนดจุดเริ่มต้นหรือปลายทาง" message:@"กรุณากำหนดจุดเริ่มต้นและปลายทางให้เรียบร้อย" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
        }];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        if (![goDate isEqualToString:@""]) {
            NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
            [df1 setLocale:localeTH];
            [df1 setDateFormat:@"yyyy-MM-dd"];
            NSDate *ceYear = [df1 dateFromString:goDate];
            
            localeEN = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
            [df2 setLocale:localeEN];
            [df2 setDateFormat:@"yyyy-MM-dd"];
            goDateEN = [df2 stringFromDate:ceYear];
        }
        else{
            goDateEN = @"";
        }
        
        NSLog(@"userID:%@\n From:%@\n To:%@\n origin:%@\n destination:%@\n goDate:%@",sharedManager.memberID,searchCell.fromField.text,searchCell.toField.text,fromID,toID,goDateEN);
        
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
        [self finishSearch];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"!DidFailLoadWithError: %@", [error description]);
    //self.view.alpha = 1.f;
    [HUD dismissAnimated:YES];
    [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
}

- (void)finishSearch
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@search",HOST_DOMAIN];
    NSDictionary *parameters = @{@"userEmail":sharedManager.memberID,
                                 @"dateSearch":goDateEN,
                                 };
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"Search %@",responseObject);
         
         searchJSON = [[responseObject objectForKey:@"data"] mutableCopy];
         if ([searchJSON count] == 0) {
             notFound = YES;
         }
         else{
             notFound = NO;
         }
         
         [mycollectionView reloadData];
         
         [HUD dismissAnimated:YES];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [HUD dismissAnimated:YES];
         [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
     }];
    webLoaded = NO;
}

- (IBAction)requestClick:(id)sender
{
    [self.tabBarController setSelectedIndex:2];
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

@end
