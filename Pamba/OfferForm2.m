//
//  OfferForm2.m
//  Pamba
//
//  Created by Firststep Consulting on 7/13/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "OfferForm2.h"
#import "MainCell.h"
#import "ProfileOffer.h"

@interface OfferForm2 () <GMSAutocompleteViewControllerDelegate>

@end

@implementation OfferForm2
{
    GMSAutocompleteResultsViewController *_resultsViewController;
}

@synthesize fromID,fromName,toID,toName,distance,duration,goDate,goH,goM,exTime,seats,luggage,option,price,remark,waypoint,carType;

@synthesize bgView,headerView,headerTitle,myTable,tableViewHeight,checkTitle,checkBox1,checkBox2,checkBox3,checkBox4,checkLabel1,checkLabel2,checkLabel3,checkLabel4,remarkTitle,remarkText,pickTitle,greenBtn,orangeBtn,backBtn;

- (void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = NO;
    self.tabBarController.tabBar.hidden = NO;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"OfferForm2"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sharedManager = [Singleton sharedManager];
    
    [backBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"th"];
    [df setLocale:locale];
    NSDate *ceYear = [df dateFromString:goDate];
    
    locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [df setLocale:locale];
    goDate = [df stringFromDate:ceYear];
    
    NSLog(@"userID:%@\n From:%@\n FromID:%@\n To:%@\n ToID:%@\n distance:%@\n duration:%@\n goDate:%@\n goH:%@\n goM:%@\n exTime:%@\n seats:%@\n luggage:%@\n price:%@",sharedManager.memberID,fromName,fromID,toName,toID,distance,duration,goDate,goH,goM,exTime,seats,luggage,price);
    
    headerTitle.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+4];
    [self shorttext:headerTitle];
    
    checkTitle.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+3];
    [self shorttext:checkTitle];
    
    smoke = YES;
    food = YES;
    pet = YES;
    music = NO;
    
    [checkBox1.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [checkBox2.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [checkBox3.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [checkBox4.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    checkLabel1.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2];
    [self shorttext:checkLabel1];
    checkLabel2.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2];
    [self shorttext:checkLabel2];
    checkLabel3.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2];
    [self shorttext:checkLabel3];
    checkLabel4.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2];
    [self shorttext:checkLabel4];
    
    remarkTitle.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+3];
    [self shorttext:remarkTitle];
    
    remarkText.delegate = self;
    remarkText.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2];
    remarkText.layer.borderWidth = 1.0f;
    remarkText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    pickTitle.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+3];
    [self shorttext:pickTitle];
    
    [orangeBtn.titleLabel setFont:[UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+6]];
    
    pickupArray = [[NSMutableArray alloc] init];
    myTable.editing = YES;
    
    option = @"smoking-food--pet";
    smokeString = @"smoking";
    foodString = @"food";
    musicString = @"";
    petString = @"pet";
    remark = @"";
    waypoint = @"";
}

- (IBAction)checkClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == 101) {//Smoke
        if (smoke == YES) {
            smoke = NO;
            smokeString = @"";
            [button setImage:[UIImage imageNamed:@"form_check_off"] forState:UIControlStateNormal];
        }
        else
        {
            smoke = YES;
            smokeString = @"smoking";
            [button setImage:[UIImage imageNamed:@"form_check_on"] forState:UIControlStateNormal];
        }
    }
    if (button.tag == 102) {//Food
        if (food == YES) {
            food = NO;
            foodString = @"";
            [button setImage:[UIImage imageNamed:@"form_check_off"] forState:UIControlStateNormal];
        }
        else
        {
            food = YES;
            foodString = @"food";
            [button setImage:[UIImage imageNamed:@"form_check_on"] forState:UIControlStateNormal];
        }
    }
    if (button.tag == 103) {//Pet
        if (pet == YES) {
            pet = NO;
            petString = @"";
            [button setImage:[UIImage imageNamed:@"form_check_off"] forState:UIControlStateNormal];
        }
        else
        {
            pet = YES;
            petString = @"pet";
            [button setImage:[UIImage imageNamed:@"form_check_on"] forState:UIControlStateNormal];
        }
    }
    if (button.tag == 104) {//Music
        if (music == YES) {
            music = NO;
            musicString = @"";
            [button setImage:[UIImage imageNamed:@"form_check_off"] forState:UIControlStateNormal];
        }
        else
        {
            music = YES;
            musicString =@"music";
            [button setImage:[UIImage imageNamed:@"form_check_on"] forState:UIControlStateNormal];
        }
    }
    option = [NSString stringWithFormat:@"%@-%@-%@-%@",smokeString,foodString,musicString,petString];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"ใส่รายละเอียด..."]) {
        textView.text = @"";
        //textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"ใส่รายละเอียด...";
        //textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [pickupArray count];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.frame.size.width*0.08;//UITableViewAutomaticDimension;
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    MainCell *cell = (MainCell *)[tableView dequeueReusableCellWithIdentifier:@"MainCell"];
    cell.nameLabel.text = [[pickupArray objectAtIndex:indexPath.row] objectForKey:@"placeName"];
    cell.nameLabel.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+2];
    [self shorttext:cell.nameLabel];
    
    [cell.detailBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.detailBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.detailBtn.tag = indexPath.row;
    
    return cell;
}
    
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    for(UIView* view in cell.subviews)
    {
        if([[[view class] description] isEqualToString:@"UITableViewCellReorderControl"])
        {
            // Creates a new subview the size of the entire cell
            UIView *movedReorderControl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(view.frame), CGRectGetMaxY(view.frame))];
            // Adds the reorder control view to our new subview
            [movedReorderControl addSubview:view];
            // Adds our new subview to the cell
            [cell addSubview:movedReorderControl];
            // CGStuff to move it to the left
            CGSize moveLeft = CGSizeMake(movedReorderControl.frame.size.width - view.frame.size.width, movedReorderControl.frame.size.height - view.frame.size.height);
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformTranslate(transform, -moveLeft.width, -moveLeft.height);
            // Performs the transform
            [movedReorderControl setTransform:transform];
        }
    }
}
    
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [pickupArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //tableViewHeight.constant = myTable.contentSize.height;
            //[self.view updateConstraints];
        });
        NSLog(@"Delete %@",pickupArray);
    }
}
    
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    id objectToMove = [pickupArray objectAtIndex:fromIndexPath.row];
    [pickupArray removeObjectAtIndex:fromIndexPath.row];
    [pickupArray insertObject:objectToMove atIndex:toIndexPath.row];
    [tableView reloadData];
    NSLog(@"Reorder %@",pickupArray);
}

- (void)deleteClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [pickupArray removeObjectAtIndex:button.tag];
    [myTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [myTable reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        //tableViewHeight.constant = myTable.contentSize.height;
        //[self.view updateConstraints];
    });
    NSLog(@"Delete %@",pickupArray);
}

- (IBAction)greenClick:(id)sender
{
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    acController.tableCellBackgroundColor = [UIColor whiteColor];
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    //filter.type = kGMSPlacesAutocompleteTypeFilterRegion;
    filter.country = @"TH";
    acController.autocompleteFilter = filter;
    [self presentViewController:acController animated:YES completion:nil];
    
    /*
    NSString *test = [NSString stringWithFormat:@"test %lu",(unsigned long)[pickupArray count]];
    [pickupArray addObject:test];
    [myTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[pickupArray count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [myTable reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        //tableViewHeight.constant = myTable.contentSize.height;
        //[self.view updateConstraints];
    });
    
    NSLog(@"Add %@",pickupArray);
    */
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
    
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json"];
    NSDictionary *parameters = @{@"placeid":place.placeID,
                                 @"key":sharedManager.GoogleAPIKey
                                 };
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"latlongJSON %@",responseObject);
         
         NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc]init];
         [mutableDict setObject:place.placeID forKey:@"placeID"];
         [mutableDict setObject:place.name forKey:@"placeName"];
         [mutableDict setObject:place.formattedAddress forKey:@"placeAddress"];
         if (place.attributions.string) {
             [mutableDict setObject:place.attributions.string forKey:@"placeAttribution"];
         }
         NSDictionary *latlongDict = [[[responseObject objectForKey:@"result"] objectForKey:@"geometry"] objectForKey:@"location"];
         [mutableDict setObject:[latlongDict objectForKey:@"lat"] forKey:@"placeLat"];
         [mutableDict setObject:[latlongDict objectForKey:@"lng"] forKey:@"placeLng"];
         
         [pickupArray addObject:mutableDict];
         [myTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[pickupArray count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
         [myTable reloadData];
         dispatch_async(dispatch_get_main_queue(), ^{
             //tableViewHeight.constant = myTable.contentSize.height;
             //[self.view updateConstraints];
         });
         
         NSLog(@"Add %@",pickupArray);
         
         [HUD dismissAnimated:YES];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [HUD dismissAnimated:YES];
         [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
     }];
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

- (IBAction)orangeClick:(id)sender
{
    if ([remarkText.text isEqualToString:@"ใส่รายละเอียด..."]) {
        remark = @"";
    }
    else
    {
        remark = remarkText.text;
    }
    
    waypoint = @"";
    NSString *seperator;
    for (int i=0; i < [pickupArray count]; i++) {
        NSMutableDictionary *waypointDict = [pickupArray objectAtIndex:i];
        
        if ([pickupArray count]-1 == i) {
            seperator = @"";
        }
        else{
            seperator = @"|";
        }
        
        waypoint = [NSString stringWithFormat:@"%@%@,%@,%@%@",waypoint,[waypointDict objectForKey:@"placeName"],[waypointDict objectForKey:@"placeLat"],[waypointDict objectForKey:@"placeLng"],seperator];
    }
    
    NSLog(@"option:%@\n price:%@\n remark:%@\n way_point:%@",option,price,remark,waypoint);
    
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
        [self finishOffer];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"!DidFailLoadWithError: %@", [error description]);
    //self.view.alpha = 1.f;
    [HUD dismissAnimated:YES];
    [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
}

- (void)finishOffer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@createOffer",HOST_DOMAIN];
    NSDictionary *parameters = @{@"userEmail":sharedManager.memberID,
                                 @"From":fromName,
                                 @"To":toName,
                                 @"distance":distance,
                                 @"duration":duration,
                                 @"start_address":@"",
                                 @"end_address":@"",
                                 @"origin":fromID,
                                 @"destination":toID,
                                 @"goDate":goDate,
                                 @"goH":goH,
                                 @"goM":goM,
                                 @"exTime":exTime,
                                 @"seats":seats,
                                 @"luggage":luggage,
                                 @"option":option,
                                 @"price":price,
                                 @"remark":remark,
                                 @"way_point":waypoint,
                                 @"type":carType,
                                 };
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"Offer %@",responseObject);
         
         HUD.textLabel.text = @"การเสนอที่นั่งถูกบันทึกแล้ว";
         HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
         [HUD dismissAfterDelay:3.0 animated:YES];
         
         sharedManager.reloadOffer = YES;
         sharedManager.clearOffer = YES;
         
         ProfileOffer *pfo = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileOffer"];
         pfo.mode = @"Offer";
         [self.navigationController pushViewController:pfo animated:YES];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error %@",error);
         [HUD dismissAnimated:YES];
         [self alertTitle:@"เกิดข้อผิดพลาด" detail:@"กรุณาตรวจสอบ Internet ของท่านแล้วลองใหม่อีกครั้ง"];
     }];
    webLoaded = NO;
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
    
    /*Update Table View Hieght
     dispatch_async(dispatch_get_main_queue(), ^{
     //This code will run in the main thread:
     CGRect frame = myTable.frame;
     frame.size.height = myTable.contentSize.height;
     myTable.frame = frame;
     });
     */

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
