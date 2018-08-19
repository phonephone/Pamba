//
//  ChatList.m
//  Pamba
//
//  Created by Firststep Consulting on 8/25/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "ChatList.h"
#import "ChatCell.h"
#import "UIImageView+WebCache.h"
#import "Web.h"
#import "RightMenu.h"

@interface ChatList ()

@end

@implementation ChatList

@synthesize bgView,headerView,headerTitle,myTable,backBtn;

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    self.menuContainerViewController.panMode = NO;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"ChatList"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self loadList];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sharedManager = [Singleton sharedManager];
    
    myTable.layer.masksToBounds = YES;
    // *** Set light gray color as shown in sample ***
    myTable.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    myTable.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    myTable.layer.shadowRadius = 5.0f;
    
    // *** Set shadowOpacity to full (1) ***
    myTable.layer.shadowOpacity = 0.7f;
    
    self.tabBarController.tabBar.hidden = YES;
    
    [backBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    headerTitle.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+4];
    [self shorttext:headerTitle];
}

- (void)loadList
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* url = [NSString stringWithFormat:@"%@get_message_all",HOST_DOMAIN];
    NSDictionary *parameters = @{@"userEmail":sharedManager.memberID};
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"listJSON %@",responseObject);
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
    int rowNo;
    
    if ([[[listJSON objectAtIndex:0] allKeys] containsObject:@"status"]) {rowNo = 0;}
    else{
        rowNo = [listJSON count];
    }
    return rowNo;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float rowHeight = myTable.frame.size.height/6;
    
    return rowHeight;//UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatCell *cell = (ChatCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:188.0/255 green:188.0/255 blue:188.0/255 alpha:1];;
    [cell setSelectedBackgroundView:bgColorView];
    
    NSDictionary *cellArray = [listJSON objectAtIndex:indexPath.row];
    
    cell.chatAlert.hidden = YES;
    
    [cell.chatUserPic sd_setImageWithURL:[NSURL URLWithString:[cellArray objectForKey:@"userPic"]] placeholderImage:[UIImage imageNamed:@"icon1024.png"]];
    cell.chatUserPic.layer.cornerRadius = cell.chatUserPic.frame.size.width/2;
    cell.chatUserPic.layer.masksToBounds = YES;
    
    cell.chatUserName.text = [cellArray objectForKey:@"name"];
    cell.chatUserName.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+6];
    [self shorttext:cell.chatUserName];
    
    //cell.chatLastMessage.text = [cellArray objectForKey:@"checkLastMessage"];
    cell.chatLastMessage.attributedText = [[NSAttributedString alloc] initWithData:[[cellArray objectForKey:@"checkLastMessage"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
    cell.chatLastMessage.font = [UIFont fontWithName:@"Kanit-Light" size:sharedManager.fontSize];
    [self shorttext:cell.chatLastMessage];
    
    int chatAlert = [[cellArray objectForKey:@"notification_chat"] intValue];
    if (chatAlert > 0)
    {
        cell.chatAlert.hidden = NO;
    }
    else{
        cell.chatAlert.hidden = YES;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Web *web = [self.storyboard instantiateViewControllerWithIdentifier:@"Web"];
    web.webTitle = @"";
    web.urlString = [NSString stringWithFormat:@"%@ChatWV/message?userFrom=%@&userTo=%@",HOST_DOMAIN_INDEX,sharedManager.memberID,[[listJSON objectAtIndex:indexPath.row] objectForKey:@"user"]];
    [web setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self.navigationController pushViewController:web animated:YES];
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

- (IBAction)back:(id)sender
{
    RightMenu *rm = (RightMenu*)[sharedManager.mainRoot.childViewControllers objectAtIndex:0];
    [rm loadProfile];
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
