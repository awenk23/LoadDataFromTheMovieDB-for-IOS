//
//  ATPageFlipper.h
//  TestAnimate
//
//  Created by i'Mac on 8/8/14.
//  Copyright (c) 2014 magato. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ATPageFlipperDirectionLeft,
	ATPageFlipperDirectionRight,
} ATPageFlipperDirection;


@class ATPageFlipper;

@protocol ATPageFlipperDataSource <NSObject>

- (NSInteger) numberOfPagesForPageFlipper:(ATPageFlipper *) pageFlipper;
- (UIView *) viewForPage:(NSInteger) page inFlipper:(ATPageFlipper *) pageFlipper;

@end


@protocol ATPageFlipperDelegate <NSObject>

@optional

-(void) pageFlipper:(ATPageFlipper*)pageFlipper willFlipToPage:(NSInteger)page;
-(void) pageFlipper:(ATPageFlipper*)pageFlipper willCancelToPage:(NSInteger)page;
-(void) didReachStartForFlipper:(ATPageFlipper*)pageFlipper ;


@end


@interface ATPageFlipper : UIView

@property (nonatomic, assign) id<ATPageFlipperDelegate> delegate;
@property (nonatomic, assign) id<ATPageFlipperDataSource> dataSource;

@property (nonatomic, readwrite) CGFloat duration;
@property (nonatomic, readwrite) NSInteger currentPage;
@property (nonatomic, readwrite) BOOL disablePanning;

//@property (nonatomic, readwrite) ATTransitionType type;
//@property (nonatomic, readwrite) ATTransitionDirection direction;
//@property (nonatomic, assign) UINavigationController* navigationController;
//@property (nonatomic, readwrite) BOOL interactive;

//-(id) initWithNavigationController:(UINavigationController*) navigationController type:(ATTransitionType)type duration:(CGFloat)duration;

-(id) initWithDuration:(CGFloat)duration;
-(void) deletePage:(NSInteger)page;
-(void) reloadPage;
-(void) flipNext:(CGFloat)delayTime;

@end
