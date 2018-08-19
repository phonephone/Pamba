//
//  MenuCell.m
//  Pamba
//
//  Created by Firststep Consulting on 7/7/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell
@synthesize menuLabel,menuAlert,menuArrow;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
