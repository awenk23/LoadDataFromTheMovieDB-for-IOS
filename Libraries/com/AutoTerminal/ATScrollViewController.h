//
//  ATScrollViewController.h
//  ATNZ
//
//  Created by i'Mac on 1/21/13.
//  Copyright (c) 2013 AutoTerminal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPageControl.h"

@class ATScrollViewController;

@protocol ATScrollViewControllerDelegate <NSObject>

@optional
-(void) scrollViewController:(ATScrollViewController*) scrollViewController tapReceivedOnPage:(NSInteger)pageNumber;
-(void) scrollViewController:(ATScrollViewController*) scrollViewController scrollToPage:(NSInteger)pageNumber;

@end

@interface ATScrollViewController : UIViewController

@property (nonatomic, retain) id<ATScrollViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, retain) DDPageControl *pageControl;
@property (nonatomic, readwrite) BOOL bounces;

@end
