//
//  UserVO.m
//  AEMC
//
//  Created by i'Mac on 12/20/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "UserVO.h"
#import "Config.h"
#import "IBCUserProxy.h"
//#import "SSKeychain.h"

// Default Keys
#define kIBCKeyUsername @"Username"
#define kIBCKeyPassword @"Password"

#define kIBCKeyLastSearchCriteria @"LastSearchCriteria"
#define kIBCKeyLastMakeRefresh @"LastMakeRefresh"
#define kIBCKeyLastReportFilter @"LastReportFilter"
#define kIBCKeyTotalResult @"TotalResult"
#define kIBCKeyLastTab @"LastTab"
#define kIBCKeyPageSize @"PageSize"
#define kIBCKeyPageCurrent @"PageCurrent"
//#define kIBCKeyLastAuctionDirectSearch @"LastAuctionDirectSearch"

#define kIBCDefaultPageSize 50


@implementation UserVO

- (id) init {
    if (self = [super init]) {
        
        // Set UserDefaults defaults
        NSDictionary* userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInt:kIBCDefaultPageSize], kIBCKeyPageSize,
                                              [NSNumber numberWithInt:0], kIBCKeyLastTab,
                                              nil];

        [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
        
    }
    
    return self;
}

- (NSNumber*) pageSize {
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:kIBCKeyPageSize];
    
}

- (void) setPageSize:(NSNumber *)pageSize {
    
    [[NSUserDefaults standardUserDefaults] setValue:pageSize forKey:kIBCKeyPageSize];
    
}
- (NSNumber*) pageCurrent {
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:kIBCKeyPageCurrent];
    
}

- (void) setPageCurrent:(NSNumber *)pageCurrent {
    
    [[NSUserDefaults standardUserDefaults] setValue:pageCurrent forKey:kIBCKeyPageCurrent];
    
}






@end
