//
//  ATLookupView.h
//  AEMC
//
//  Created by i'Mac on 12/19/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "ATListViewController.h"

@interface ATLookupView : ATListViewController

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIView *navView;

-(void) performFetch;
-(void) performRefresh;
-(void) resignView;

-(void) didFetch:(NSFetchedResultsController*)fetchedData;
-(void) didRefresh;



@end
