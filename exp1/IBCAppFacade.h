//
//  IBCAppFacade.h
//  AEMC
//
//  Created by i'Mac on 12/10/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "Facade.h"
#import "ATDatabase.h"

@interface IBCAppFacade : Facade {

}

@property (nonatomic, retain) ATDatabase* cacheData;
@property (nonatomic, retain) ATDatabase* userData;

+(IBCAppFacade *)getInstance;
-(void)startup:(id)app;


@end

