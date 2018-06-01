//
//  ATAnimationController.m
//  TestAnimate
//
//  Created by i'Mac on 8/8/14.
//  Copyright (c) 2014 magato. All rights reserved.
//

#import "ATPageFlipper.h"

#define kATCompletionSpeed 0.2f

@interface UIView(Extended)

- (UIImage *) imageByRenderingView;

@end


@implementation UIView(Extended)


- (UIImage *) imageByRenderingView {
	CGFloat oldAlpha = self.alpha;
	
	self.alpha = 1;
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	self.alpha = oldAlpha;
	
	return resultingImage;
}

@end


@interface ATPageFlipper()  {
    
    UIPanGestureRecognizer* _panRecognizer;
    //id<UIViewControllerContextTransitioning> _context;
    
    BOOL _panning;
    
    UIView* _newView;
    UIView* _currentView;
    //UIView* _nextView;
    //UIView* _prevView;

    //__weak UIImageView* _newView;
    //__weak UIImageView* _currentView;
    
    UIView* _blackOverlay;
    
    ATPageFlipperDirection _direction;
    
}

@end

@implementation ATPageFlipper

-(id) initWithDuration:(CGFloat)duration {
    
    if (self == [super init]) {
        
        self.duration = duration;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _currentPage = -1;
        
        // init and place pan recognizer
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panRecognizer.delaysTouchesBegan = NO;
        _panRecognizer.delaysTouchesEnded = NO;
        
        [self addGestureRecognizer:_panRecognizer];
        
    }
    
    return self;
    
}


#pragma mark - Properties
/*-(void) setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
}*/

- (void)setDisablePanning:(BOOL)disablePanning {
    
    _panRecognizer.enabled = !disablePanning;
    
}

-(void) setCurrentPage:(NSInteger)currentPage {
    
    if (_currentPage == currentPage) {
        return;
    }

    _currentPage = currentPage;
    
    // remove existing view from superview
    [_currentView removeFromSuperview];
    
    // retrieve new view
    
    //_currentView = [[UIImageView alloc] initWithImage:[self imageWithView:[self.dataSource viewForPage:currentPage inFlipper:self]]];
    _currentView = [self.dataSource viewForPage:currentPage inFlipper:self];
    
    if ([self.delegate respondsToSelector:@selector(pageFlipper:willFlipToPage:)]) {
        [self.delegate pageFlipper:self willFlipToPage:_currentPage];
    }
    
    _currentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _currentView.frame = self.bounds;
    
    // add to the view
    [self addSubview:_currentView];
    
    //[self preloadNextView];
    //[self preloadPrevView];
    
    /*_newView = [self.dataSource viewForPage:_currentPage + 1 inFlipper:self];
    _newView.frame = self.bounds;
    [self insertSubview:_newView aboveSubview:_currentView];
    _newView.transform = CGAffineTransformMakeTranslation(320, 0);
    */
    
    // Setup autolayout
    /*NSDictionary* views = @{@"view": _currentView};
    _currentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[view]-(0)-|" options:0 metrics:nil views:views]];
    */
}

#pragma mark - Touch delegates
-(void)handlePan:(UIPanGestureRecognizer*)sender {
    
    static CGFloat startXPos;
    static BOOL panning;
    
    CGPoint velocity = [sender velocityInView:sender.view];
    CGPoint translatedPoint = [sender translationInView:sender.view];
    CGPoint location = [sender locationInView:sender.view];
    
    // init vars
    if (startXPos == 0) {
        startXPos = location.x;
    }
    
    CGFloat percent = ABS(startXPos - location.x) / self.bounds.size.width;
    //NSLog(@"p %f, percent %f", startXPos - location.x, percent);
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            startXPos = location.x;
            break;
            
        case UIGestureRecognizerStateChanged: {
            
            if (ABS(translatedPoint.x) < ABS(translatedPoint.y)) return;
            
            if (!panning) {
                
                // set direction
                NSInteger newPage;
                
                if (translatedPoint.x < 0) {
                    _direction = ATPageFlipperDirectionLeft;
                    newPage = _currentPage + 1;
                } else {
                    _direction = ATPageFlipperDirectionRight;
                    newPage = _currentPage - 1;
                }
                
                // absolute cancel if page is less than zero or bigger than total
                
                if (newPage < 0 || newPage + 1 > [self.dataSource numberOfPagesForPageFlipper:self]) {
                    if (newPage < 0 && [self.delegate respondsToSelector:@selector(didReachStartForFlipper:)]) {
                        
                        [self.delegate didReachStartForFlipper:self];
                        
                    }
                    
                    return;
                }
                
                _currentPage = newPage;

                [self beginTransition];
                
                panning = YES;
            }
            
            [self updateTransition:percent];

            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {

            if (!panning) {
                return;
            }
            
            // cancel if speed is slow or percent is less than 30%
            BOOL cancel = (ABS(velocity.x) < 500.f && percent <= 0.3f);
            
            if (cancel) {
                [self cancelTransition];
            } else {
                [self endTransition];
            }
            
            panning = NO;
            break;
        }
            
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed:
            panning = NO;
            break;
            
    }
    
}


-(void) beginTransition {
    
    if ([self.delegate respondsToSelector:@selector(pageFlipper:willFlipToPage:)]) {
        [self.delegate pageFlipper:self willFlipToPage:_currentPage];
    }
    
    // Get references to view hierarchy
    _newView = [self.dataSource viewForPage:_currentPage inFlipper:self];
    
    _newView.frame = self.bounds;
    
    // Create black overlay
    if (_blackOverlay == nil) {
        _blackOverlay = [[UIView alloc] initWithFrame:self.bounds];
        [_blackOverlay setBackgroundColor:[UIColor blackColor]];
    }
    
    // Initial state
    if (_direction == ATPageFlipperDirectionLeft) {
        
        //_newView = _nextView;
        //_newView.frame = self.bounds;
        
        [self insertSubview:_newView aboveSubview:_currentView];
        //_currentView.transform = CGAffineTransformMakeScale(1, 1);
        //_newView.transform = CGAffineTransformMakeTranslation(self.bounds.size.width, 0);
        _currentView.layer.transform = CATransform3DMakeScale(1, 1, 1);
        _newView.layer.transform = CATransform3DMakeTranslation(self.bounds.size.width, 0, 0);
        [self insertSubview:_blackOverlay aboveSubview:_currentView];
        _blackOverlay.alpha = 0;
        

    } else {
        
        //_newView = _prevView;
        //_newView.frame = self.bounds;
        
        [self insertSubview:_newView belowSubview:_currentView];
        //_currentView.transform = CGAffineTransformMakeTranslation(0, 0);
        //_newView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
        _currentView.layer.transform = CATransform3DMakeTranslation(0, 0, 0);
        _newView.layer.transform = CATransform3DMakeScale(0.9f, 0.9f, 1);
        
        [self insertSubview:_blackOverlay belowSubview:_currentView];
        _blackOverlay.alpha = 0.8f;
        
    }
    
    // Setup autolayout
    /*NSDictionary* views = @{@"view": _newView};
    _newView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[view]-(0)-|" options:0 metrics:nil views:views]];
    */
    
}

-(void) updateTransition:(CGFloat) percent {
    
    if (_direction == ATPageFlipperDirectionLeft) {
        
        //_newView.transform = CGAffineTransformMakeTranslation(self.bounds.size.width * (1.f - percent), 0);
        //_currentView.transform = CGAffineTransformMakeScale(1.f - (0.1f * percent), 1.f - (0.1f * percent));
        
        _newView.layer.transform = CATransform3DMakeTranslation(self.bounds.size.width * (1.f - percent), 0, 0);
        _currentView.layer.transform = CATransform3DMakeScale(1.f - (0.1f * percent), 1.f - (0.1f * percent), 1);
        
        _blackOverlay.alpha = 0.8f * percent;
        
    } else {
        
        //_newView.transform = CGAffineTransformMakeScale(0.9f + (0.1f * percent), 0.9f + (0.1f * percent));
        //_currentView.transform = CGAffineTransformMakeTranslation(self.bounds.size.width * percent, 0);
        
        _newView.layer.transform = CATransform3DMakeScale(0.9f + (0.1f * percent), 0.9f + (0.1f * percent), 1);
        _currentView.layer.transform = CATransform3DMakeTranslation(self.bounds.size.width * percent, 0, 0);
        
        _blackOverlay.alpha = 0.8f * (1.f - percent);
    }
    
}

-(void) endTransition {
    
    if (_direction == ATPageFlipperDirectionLeft) {
        
        [UIView animateWithDuration:kATCompletionSpeed animations:^{
            
            //_newView.transform = CGAffineTransformMakeTranslation(0, 0);
            //_currentView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
            
            _newView.layer.transform = CATransform3DMakeTranslation(0, 0, 0);
            _currentView.layer.transform = CATransform3DMakeScale(0.9f, 0.9f, 1);
            
            _blackOverlay.alpha = 0.8f;
            
        } completion:^(BOOL finished) {
            
            // Need to reset back to original state
            //_currentView.transform = CGAffineTransformMakeScale(1, 1);
            _currentView.layer.transform = CATransform3DMakeScale(1, 1, 1);
            _currentView.layer.transform = CATransform3DMakeTranslation(0, 0, 0);
            [self endInteractiveTransition];
            
        }];
        
    } else {
        
        [UIView animateWithDuration:kATCompletionSpeed animations:^{
            
            //_newView.transform = CGAffineTransformMakeScale(1, 1);
            //_currentView.transform = CGAffineTransformMakeTranslation(self.bounds.size.width, 0);
            _newView.layer.transform = CATransform3DMakeScale(1, 1, 1);
            _currentView.layer.transform = CATransform3DMakeTranslation(self.bounds.size.width, 0, 0);
            _blackOverlay.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            // Need to reset back to original state
            _currentView.layer.transform = CATransform3DMakeScale(1, 1, 1);
            _currentView.layer.transform = CATransform3DMakeTranslation(0, 0, 0);
            [self endInteractiveTransition];
            
        }];
        
    }
    
}

-(void) cancelTransition {
    
    if (_direction == ATPageFlipperDirectionLeft) {
        
        [UIView animateWithDuration:kATCompletionSpeed animations:^{
            
            //_currentView.transform = CGAffineTransformMakeScale(1, 1);
            //_newView.transform = CGAffineTransformMakeTranslation(self.bounds.size.width, 0);
            _currentView.layer.transform = CATransform3DMakeScale(1, 1, 1);
            _newView.layer.transform = CATransform3DMakeTranslation(self.bounds.size.width, 0, 0);
            
            _blackOverlay.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            _newView.layer.transform = CATransform3DMakeTranslation(0, 0, 0);
            [self cancelInteractiveTransition];
            
        }];
        
    } else {

        [UIView animateWithDuration:kATCompletionSpeed animations:^{
            
            //_currentView.transform = CGAffineTransformMakeTranslation(0, 0);
            //_newView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
            _currentView.layer.transform = CATransform3DMakeTranslation(0, 0, 0);
            _newView.layer.transform = CATransform3DMakeScale(0.9f, 0.9f, 0.9f);
            
            _blackOverlay.alpha = 0.8f;
            
        } completion:^(BOOL finished) {
            
            // Need to reset back to 1
            //_newView.transform = CGAffineTransformMakeScale(1, 1);
            _newView.layer.transform = CATransform3DMakeScale(1, 1, 1);
            
            [self cancelInteractiveTransition];
            
        }];
        
    }
 
    [self.delegate pageFlipper:self willCancelToPage:_currentPage];
    
}

-(void) cancelInteractiveTransition {
    
    [_newView removeFromSuperview];
    _newView = nil;
    
    [_blackOverlay removeFromSuperview];
 
    // return to previous page
    if (_direction == ATPageFlipperDirectionLeft) {
        _currentPage--;
    } else {
        _currentPage++;
    }
    
}

-(void) endInteractiveTransition {
    
    [_currentView removeFromSuperview];
    
    // keep reference of currentView and preload next view
    /*if (_direction == ATPageFlipperDirectionLeft) {
        _prevView = _currentView;
        [self preloadNextView];

    // keep reference of currentView and preload prev view
    } else {
        _nextView = _currentView;
        [self preloadPrevView];
    }*/
    
    _currentView = _newView;
    _newView = nil;

    [_blackOverlay removeFromSuperview];
    
}


/*- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}*/

/*-(void) preloadNextView {

    // preload next view
    if (_currentPage < [self.dataSource numberOfPagesForPageFlipper:self] - 1) {
        _nextView = [self.dataSource viewForPage:_currentPage + 1 inFlipper:self];
    } else {
        _nextView = nil;
    }
}

-(void) preloadPrevView {

    // preload prev view
    if (_currentPage > 0) {
        _prevView = [self.dataSource viewForPage:_currentPage - 1 inFlipper:self];
    } else {
        _prevView = nil;
    }
}*/


#pragma mark - Public methods
-(void) deletePage:(NSInteger)page {
    
    // force page refresh
    _currentPage = -1; // to force reload
    
    [self setCurrentPage:page];
    
}

-(void) reloadPage {
    
    NSInteger page = _currentPage;
    
    _currentPage = -1; // to force reload
    
    [self setCurrentPage:page];
    
}

-(void) flipNext:(CGFloat)delayTime {
    
    _direction = ATPageFlipperDirectionLeft;
    
    // cancel if reached the end
    if (_currentPage + 2 > [self.dataSource numberOfPagesForPageFlipper:self]) {
        return;
    }
    
    _currentPage = _currentPage + 1;
    
    // delay transition after n seconds
    [UIView animateWithDuration:delayTime animations:nil completion:^(BOOL finished) {
        [self beginTransition];
        [self endTransition];
    }];
    
}

@end
