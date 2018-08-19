//
//  Tabbar.m
//  Pamba
//
//  Created by Firststep Consulting on 7/7/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "Tabbar.h"
#import "Singleton.h"

@interface Tabbar ()

@end

@implementation Tabbar

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Singleton *sharedManager = [Singleton sharedManager];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize-2], NSFontAttributeName, nil] forState:UIControlStateNormal];
    //[[UITabBar appearance] setTintColor:[UIColor redColor]];
    //[[UITabBar appearance] setAlpha:0.25];
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
