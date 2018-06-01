//
//  Config.h
//  exp1
//
//  Created by imac on 29/05/18.
//  Copyright © 2018 paytren. All rights reserved.
//

#ifndef Config_h
#define Config_h


// JSON Urls
#define kATURLJSON @"http://bitvmweb.icomm.corp:90/api/json/reply/"
//#define kATURLJSON @"https://webservices4.ibcjapan.co.jp/api/json/reply/"
//#define kATURLJSON @"http://bitvmweb.icomm.corp:8130/api/json/reply/"

#define BY_PASS_LOGIN NO

// Colors
#define kIBCGreenTint [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]
#define kIBCWhiteTint [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]
#define kIBCDarkBlueTint [UIColor colorWithRed:10.0/255 green:54.0/255 blue:114.0/255 alpha:.85f]
#define kIBCLightGrayTint [UIColor colorWithRed:212.0/255.0 green:212.0/255.0 blue:212.0/255.0 alpha:1.0f]
#define kIBCColorTextDark [UIColor colorWithRed:52.0/255.0 green:54.0/255.0 blue:61.0/255.0 alpha:1.0f]
#define kIBCColorTextShadow [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f]
#define kIBCColorTableBackground [UIColor colorWithRed:49.0/255.0 green:51.0/255.0 blue:56.0/255.0 alpha:1.0f]
#define kIBCColorTableSeparator [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.25f]
#define kIBCColorRedTint [UIColor colorWithRed:227.0/255.0 green:0 blue:75.0/255.0 alpha:1.0f]
#define kIBCColorAquaBlue [UIColor colorWithRed:21.f/255.f green:126.f/255.f blue:251.f/255.f alpha:1]
#define kIBCColorDarkBlue [UIColor colorWithRed:14.f/255.f green:46.f/255.f blue:81.f/255.f alpha:1]

// Pure MVC Messages - Mediators
#define kMVCStartup @"Startup"
#define kMVCResignListView @"ResignListView"
#define kMVCClearData @"ClearData"
#define kMVCLogout @"Logout"

// Notification Center
#define kIBCReceivedPushNotification @"IBCReceivedPushNotification"


// General Categories (for iOS7 below)

@implementation NSString (Contains)

- (BOOL)containsString:(NSString*)other {
    NSRange range = [self rangeOfString:other];
    return range.length != 0;
}

@end

#endif /* Config_h */
