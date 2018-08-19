//
//  ChatCell.m
//  Pamba
//
//  Created by Firststep Consulting on 8/25/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell

@synthesize chatAlert,chatUserPic,chatUserName,chatLastMessage;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
