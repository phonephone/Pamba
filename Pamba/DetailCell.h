//
//  DetailCell.h
//  Pamba
//
//  Created by Firststep Consulting on 7/9/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *detailHeadLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UILabel *pickHeadLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickLabel;

@property (weak, nonatomic) IBOutlet UILabel *extimeLabel;
@end
