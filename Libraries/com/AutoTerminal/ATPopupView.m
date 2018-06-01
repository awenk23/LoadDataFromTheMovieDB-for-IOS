//
//  ATPopupView.m
//  AEMC
//
//  Created by i'Mac on 11/12/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "ATPopupView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ATPopupView

@synthesize isRunning = _isRunning;

- (id)initWithView:(UIView*)view text:(NSString*)text
{
    CGPoint center = CGPointMake (view.center.x, view.center.y);
    self = [self initWithCenter:center text:text];
    
    if (self) {
        // add self to the view
        [view addSubview:self];
    }
    
    return self;
}

- (id)initWithCenter:(CGPoint)center text:(NSString*)text
{
    self = [super initWithFrame:CGRectMake(0, 0, 140, 35)];
    if (self) {
        
        // Initialization code
        UIView* backgroundView = [[UIView alloc] initWithFrame:self.frame];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0.70f;
        backgroundView.layer.cornerRadius = 7;
        [self addSubview:backgroundView];
        
        self.backgroundColor = [UIColor clearColor];
        //self.alpha = 0.75f;
        //self.layer.cornerRadius = 5;
        self.center = center;
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        //_activityIndicator.hidesWhenStopped = YES;
        //_activityIndicator.hidden = YES;
        [_activityIndicator startAnimating];
        _activityIndicator.frame = CGRectMake(105, 7, 20, 20);

        // Create label
        _labelStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 118, 21)];
        _labelStatus.backgroundColor = [UIColor clearColor];
        _labelStatus.font = [UIFont boldSystemFontOfSize:14.0f];
        _labelStatus.textColor = [UIColor whiteColor];
        _labelStatus.textAlignment = NSTextAlignmentLeft;
        _labelStatus.text = text;
        
        // Add to view
        [self addSubview:_activityIndicator];
        [self addSubview:_labelStatus];
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
        
        _isRunning = YES;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    _labelStatus = nil;
    _activityIndicator = nil;
}


- (void)remove
{
    _isRunning = NO;

    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
