//
//  IBCUserProxy.h
//  AEMC
//
//  Created by i'Mac on 12/20/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "ATProxy.h"
#import "UserVO.h"

@interface IBCUserProxy : ATProxy

// MVC Notification Constants
+(NSString *)NAME;
+(NSString *)NOWPLAYING_SUCCESS ;
+(NSString *)SIMILIAR_SUCCESS ;
//+(NSString *)APP_HAS_UPDATE;


// Proxy Operations
-(id) data;
-(id) dataNowPlaying ;

-(id) dataSimiliar ;
-(void)getNowPlaying:(NSString*)page;
-(void)getSimiliar:(NSString*)simId page:(NSString*)page;

@end
