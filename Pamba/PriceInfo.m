//
//  PriceInfo.m
//  Pamba
//
//  Created by Firststep Consulting on 7/13/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "PriceInfo.h"

@interface PriceInfo ()

@end

@implementation PriceInfo

@synthesize distanceInfo,publicPrice,meterPrice,titleInfo,detailInfo;
    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sharedManager = [Singleton sharedManager];
    
    titleInfo.font = [UIFont fontWithName:@"Kanit-Medium" size:sharedManager.fontSize+2];
    detailInfo.font = [UIFont fontWithName:@"Kanit-Regular" size:sharedManager.fontSize+2];
    detailInfo.text = [NSString stringWithFormat:@"ระยะทางทั้งสิ้น : %@ กม.\nคำนวณตามขนส่งสาธารณะ : %@ บาท\nคำนวณตามมิเตอร์ เริ่มต้น : %@ บาท",distanceInfo,publicPrice,meterPrice];
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
