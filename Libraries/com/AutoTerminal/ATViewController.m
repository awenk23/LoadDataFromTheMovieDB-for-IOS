//
//  ATViewController.m
//  AEMC
//
//  Created by i'Mac on 12/31/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "ATViewController.h"

@interface ATViewController () {

}

@end

@implementation ATViewController

@synthesize mediatorName, viewComponent, facade;

#pragma mark - View Delegates
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // PureMVC stuffs
        self.facade = [IBCAppFacade getInstance];
		[self initializeMediator];
        
    }
    return self;

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view

}

- (void)viewDidUnload {
    
    [super viewDidUnload];

}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (BOOL) shouldAutorotate {
    
    return YES;

}

- (NSUInteger) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}

#pragma mark - IMediator implementations

+(id)mediator {
	return [[self alloc] initWithMediatorName:nil viewComponent:nil];
}

+(id)withMediatorName:(NSString *)mediatorName {
	return [[self alloc] initWithMediatorName:mediatorName viewComponent:nil];
}

+(id)withMediatorName:(NSString *)mediatorName viewComponent:(id)viewComponent {
	return [[self alloc] initWithMediatorName:mediatorName viewComponent:viewComponent];
}

+(id)withViewComponent:(id)viewComponent {
	return [[self alloc] initWithMediatorName:nil viewComponent:viewComponent];
}

-(id)initWithMediatorName:(NSString *)_mediatorName viewComponent:(id)_viewComponent {
	if (self = [super init]) {
		self.mediatorName = (_mediatorName == nil) ? [[self class] NAME] : _mediatorName;
		self.viewComponent = _viewComponent;
        //self.notifier = [[Notifier alloc] init];
		[self initializeMediator];
	}
	return self;
}

/**
 * The name of the <code>Mediator</code>.
 *
 * <P>
 * Typically, a <code>Mediator</code> will be written to serve
 * one specific control or group controls and so,
 * will not have a need to be dynamically named.</P>
 */
+(NSString *)NAME {
    return NSStringFromClass([self class]);
}

/**
 * Initialize the Mediator instance.
 *
 * <P>
 * Called automatically by the constructor, this
 * is your opportunity to initialize the Mediator
 * instance in your subclass without overriding the
 * constructor.</P>
 *
 * @return void
 */
-(void)initializeMediator {
    self.mediatorName = NSStringFromClass([self class]);
}

/**
 * Handle <code>INotification</code>s.
 *
 * <P>
 * Typically this will be handled in a switch statement,
 * with one 'case' entry per <code>INotification</code>
 * the <code>Mediator</code> is interested in.
 */
-(void)handleNotification:(id<INotification>)notification {}

/**
 * List the <code>INotification</code> names this
 * <code>Mediator</code> is interested in being notified of.
 *
 * @return Array the list of <code>INotification</code> names
 */
-(NSArray *)listNotificationInterests {
	return [NSArray array];
}

/**
 * Called by the View when the Mediator is registered
 */
-(void)onRegister {}

/**
 * Called by the View when the Mediator is removed
 */
-(void)onRemove {}

-(void)dealloc {
    self.facade = nil;
	self.mediatorName = nil;
	self.viewComponent = nil;
}

@end
