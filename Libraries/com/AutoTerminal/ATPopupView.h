//
//  ATPopupView.h
//  AEMC
//
//  Created by i'Mac on 11/12/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATPopupView : UIView

@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, retain) UILabel* labelStatus;


- (id)initWithView:(UIView*)view text:(NSString*)text;
- (id)initWithCenter:(CGPoint)center text:(NSString*)text;
- (void)remove;

@end
