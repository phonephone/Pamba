//
//  Singleton.m
//  Pamba
//
//  Created by Firststep Consulting on 9/7/18.
//  Copyright © 2018 TMA Digital. All rights reserved.
//

#import "Singleton.h"

@import GooglePlaces;

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation Singleton

@synthesize homeExisted,reloadOffer,reloadRequest,clearOffer,clearRequest,loginStatus;

@synthesize fontSize,GoogleAPIKey,memberID,memberToken,sortMode,latitude,longitude,mainThemeColor,subThemeColor,btnThemeColor,profileJSON,mainRoot,mainTabbar;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static Singleton *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        GAI *gai = [GAI sharedInstance];
        [gai trackerWithTrackingId:@"UA-92210509-1"];
        
        GoogleAPIKey = @"AIzaSyBszQzhwq0TuUmWZVZ1bWf_AGhwExtUbqo";
        [GMSPlacesClient provideAPIKey:GoogleAPIKey];
        //[GMSServices provideAPIKey:@"YOUR_API_KEY"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"th", nil] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        mainThemeColor = [UIColor colorWithRed:61.0/255 green:166.0/255 blue:220.0/255 alpha:1];
        subThemeColor = [UIColor colorWithRed:243.0/255 green:165.0/255 blue:39.0/255 alpha:1];
        btnThemeColor = [UIColor colorWithRed:222.0/255 green:122.0/255 blue:44.0/255 alpha:1];
        
        memberID = @"";
        memberToken = @"";
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        loginStatus = [ud boolForKey:@"loginStatus"];
        
        if (loginStatus == YES) {
            memberID = [ud stringForKey:@"memberID"];
            NSLog(@"LOG IN %@",memberID);
        }
        else{
            NSLog(@"LOG OUT");
        }
        
        //loginStatus = NO;
        //loginStatus = YES;
        
        sortMode = @"";
        latitude = @"";
        longitude = @"";
        
        if (IS_IPHONE) {
            float factor = [UIScreen mainScreen].bounds.size.width/320;
            fontSize = 13*factor;
        }
        if (IS_IPAD) {
            float factor = [UIScreen mainScreen].bounds.size.width/768;
            fontSize = 25*factor;
        }
    }
    return self;
}

@end
