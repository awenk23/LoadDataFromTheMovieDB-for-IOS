//
//  ATScrollViewController.m
//  ATNZ
//
//  Created by i'Mac on 1/21/13.
//  Copyright (c) 2013 AutoTerminal. All rights reserved.
//

#import "ATScrollViewController.h"

@interface ATScrollViewController() <UIScrollViewDelegate> {
    BOOL _pageControlUsed;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    
@end

@implementation ATScrollViewController  

#pragma mark - View Delegates
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.pageControl = [[DDPageControl alloc] init];
        self.bounces = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSAssert(self.viewControllers, @"View Controllers is not set");
    
    [self.view addSubview:self.pageControl];

    // Autolayout constraints
    NSDictionary* views = @{@"pageControl": self.pageControl};
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[pageControl]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pageControl]-15-|" options:0 metrics:nil views:views]];
    
    self.pageControl.numberOfPages = self.viewControllers.count;
    self.pageControl.currentPage = 0;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.bounces = self.bounces;
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];

    [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self loadScrollViewWithPage:(int)idx];
    }];

    UIViewController* pageOne = [self.viewControllers objectAtIndex:0];
    
    self.scrollView.contentSize = CGSizeMake(pageOne.view.frame.size.width * self.viewControllers.count, pageOne.view.frame.size.height);

    //NSLog(@"%@", NSStringFromCGSize(self.scrollView.contentSize));
    
    // this is required to avoid runtime-error (iOS7)
    [self.view layoutSubviews];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)viewDidUnload {
    
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];

}

#pragma mark - Properties
- (void) setBounces:(BOOL)bounces {
    
    self.scrollView.bounces = bounces;
    _bounces = bounces;
    
}

#pragma mark - Private methods
- (void)loadScrollViewWithPage:(NSInteger)page {
    
    if (page < 0 || page >= self.viewControllers.count) return;
    
    UIViewController* controller = [self.viewControllers objectAtIndex:page];

    if (nil == controller.view.superview) {
    
        [self.scrollView addSubview:controller.view];
        
        /*NSDictionary* views = @{@"view": controller.view};
        controller.view.translatesAutoresizingMaskIntoConstraints = YES;

        
        NSString* hFormat = [NSString stringWithFormat:@"|-%f-[view(%f)]", self.view.frame.size.width * page, self.view.frame.size.width];

        NSString* vFormat = [NSString stringWithFormat:@"V:|[view(%f)]", self.view.frame.size.height];
        
        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hFormat options:0 metrics:nil views:views]];
        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vFormat options:0 metrics:nil views:views]];
        */
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;

    }
    
}

#pragma mark - Scroll view delegates
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (_pageControlUsed) {
        return;
    }
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    if ([self.delegate respondsToSelector:@selector(scrollViewController:scrollToPage:)]) {
        [self.delegate scrollViewController:self scrollToPage:self.pageControl.currentPage];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

#pragma mark - Page control delegates
- (void)changePage:(id)sender {
    
    NSInteger page = self.pageControl.currentPage;
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    _pageControlUsed = YES;
    
    if ([self.delegate respondsToSelector:@selector(scrollViewController:scrollToPage:)]) {
        [self.delegate scrollViewController:self scrollToPage:self.pageControl.currentPage];
    }
}

#pragma mark - Tap Gesture delegates
- (IBAction)handleTap:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(scrollViewController:tapReceivedOnPage:)]) {
        [self.delegate scrollViewController:self tapReceivedOnPage:self.pageControl.currentPage];
    }
     
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    
    // handle tap only if delegate responds to the selector or when DD is tapped
    return (![touch.view isKindOfClass:[DDPageControl class]] && [self.delegate respondsToSelector:@selector(scrollViewController:tapReceivedOnPage:)]);
        
}

@end
