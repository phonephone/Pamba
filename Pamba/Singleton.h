//
//  Singleton.h
//  Pamba
//
//  Created by Firststep Consulting on 9/7/18.
//  Copyright © 2018 TMA Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MFSideMenu/MFSideMenu.h>
#import <AFNetworking/AFNetworking.h>
#import <JGProgressHUD/JGProgressHUD.h>
#import <Google/Analytics.h>
#import "Tabbar.h"

#define HOST_DOMAIN @"https://pambashare.com/v2/index.php/webApi_new/"
#define HOST_DOMAIN_INDEX @"https://pambashare.com/v2/index.php/"
#define HOST_DOMAIN_HOME @"https://pambashare.com/v2/"

@interface Singleton : NSObject

@property (nonatomic) float fontSize;
@property (strong, nonatomic) NSString *GoogleAPIKey;

@property (nonatomic) BOOL homeExisted;

@property (nonatomic) NSString *sortMode;
@property (nonatomic) NSString *latitude;
@property (nonatomic) NSString *longitude;

@property (nonatomic) BOOL reloadOffer;
@property (nonatomic) BOOL reloadRequest;

@property (nonatomic) BOOL clearOffer;
@property (nonatomic) BOOL clearRequest;

@property (nonatomic) BOOL loginStatus;
@property (strong, nonatomic) NSString *memberID;
@property (strong, nonatomic) NSString *memberToken;

@property (strong, nonatomic) UIColor *mainThemeColor;
@property (strong, nonatomic) UIColor *subThemeColor;
@property (strong, nonatomic) UIColor *btnThemeColor;

@property (strong, nonatomic) NSMutableDictionary *profileJSON;

@property (strong, nonatomic) MFSideMenuContainerViewController *mainRoot;
@property (strong, nonatomic) Tabbar *mainTabbar;

+ (id)sharedManager;

@end
