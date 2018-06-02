//
//  IBCAppFacade.m
//  AEMC
//
//  Created by i'Mac on 12/10/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "Config.h"
#import "IBCAppFacade.h"
#import "IBCStartupCommand.h"

@implementation IBCAppFacade

-(void)startup:(id)app {
	[self sendNotification:kMVCStartup body:app];
}

+(IBCAppFacade *)getInstance {
	return (IBCAppFacade *)[super getInstance];
}

-(void)initializeController {
	[super initializeController];
	[self registerCommand:kMVCStartup commandClassRef:[IBCStartupCommand class]];
    _cacheData = [[ATDatabase alloc] initWithDBName:@"MovieData" persistent:NO];
    //_userData = [[ATDatabase alloc] initWithDBName:@"MovieData" persistent:NO];
   
}

@end
