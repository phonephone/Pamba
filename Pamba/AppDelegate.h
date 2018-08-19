//
//  AppDelegate.h
//  Pamba
//
//  Created by Firststep Consulting on 2/23/17.
//  Copyright © 2017 TMA Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>
{
    Singleton *sharedManager;
}
@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) BOOL loginStatus;
@end

