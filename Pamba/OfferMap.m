//
//  OfferMap.m
//  Pamba
//
//  Created by Firststep Consulting on 7/13/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "OfferMap.h"

@interface OfferMap ()

@end

@implementation OfferMap

@synthesize offerID,bgView,headerView,headerTitle,myWebview,backBtn;

- (void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = NO;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"OfferMap"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sharedManager = [Singleton sharedManager];
    
    [backBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    headerTitle.font = [UIFont fontWithName:@"Kanit-SemiBold" size:sharedManager.fontSize+4];
    [self shorttext:headerTitle];
    
    NSString* strUrl = [NSString stringWithFormat:@"%@viewMap?oid=%@&type=offer",HOST_DOMAIN,offerID];
    NSURL *url = [NSURL URLWithString:strUrl];
    myWebview.delegate = self;
    requestURL = [[NSURLRequest alloc] initWithURL:url];
    //[self.webView setAllowsInlineMediaPlayback:YES];
    //self.webView.mediaPlaybackRequiresUserAction = NO;
    [myWebview loadRequest:requestURL];
    
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
}
    
#pragma mark - UIWebViewDelegate
    
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Did start loading: %@", [[request URL] absoluteString]);
    return YES;
}
    
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //self.view.alpha = 1.f;
    [HUD dismissAnimated:YES];
}
    
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"!DidFailLoadWithError: %@", [error description]);
    //self.view.alpha = 1.f;
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
