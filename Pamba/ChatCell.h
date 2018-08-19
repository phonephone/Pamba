//
//  ChatCell.h
//  Pamba
//
//  Created by Firststep Consulting on 8/25/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *chatUserName;
@property (weak, nonatomic) IBOutlet UILabel *chatLastMessage;
@property (weak, nonatomic) IBOutlet UIImageView *chatUserPic;
@property (weak, nonatomic) IBOutlet UIImageView *chatAlert;
@end
