//
//  ATViewController.h
//  AEMC
//
//  Created by i'Mac on 12/31/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMediator.h"
#import "IBCAppFacade.h"

@interface ATViewController : UIViewController <IMediator> {
    NSString* mediatorName;
    id viewComponent;
    IBCAppFacade* facade;
}

@property(nonatomic, retain) id viewComponent;
@property(nonatomic, retain) NSString *mediatorName;
@property(nonatomic, retain) IBCAppFacade *facade;

+(id)mediator;
+(id)withMediatorName:(NSString *)mediatorName;
+(id)withMediatorName:(NSString *)mediatorName viewComponent:(id)viewComponent;
+(id)withViewComponent:(id)viewComponent;
-(id)initWithMediatorName:(NSString *)mediatorName viewComponent:(id)viewComponent;
-(void)initializeMediator;

+(NSString *)NAME;


@end
