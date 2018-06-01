//
//  IBCStartupCommand.m
//  AEMC
//
//  Created by i'Mac on 12/11/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "IBCStartupCommand.h"
#import "IBCUserProxy.h"


@implementation IBCStartupCommand

-(void)execute:(id<INotification>)notification {
    // register proxies
   
    [facade registerProxy:[IBCUserProxy proxy]];
    
}

@end
