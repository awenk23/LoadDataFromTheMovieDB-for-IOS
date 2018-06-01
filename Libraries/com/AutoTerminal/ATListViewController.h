//
//  ATListViewController.h
//  AEMC
//
//  Created by i'Mac on 10/5/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ATPopupView.h"
#import "ATJSONRequest.h"
#import "ATViewController.h"

//@class ATListViewController;
/*
@protocol ATListViewDelegate <NSObject>

@optional
- (void) ATListViewController:(ATListViewController *)controller didSelect:(id)selectedItem;
@end
*/
@interface ATListViewController : ATViewController
@property (nonatomic, retain) NSFetchedResultsController* fetchedData;
@property (nonatomic, readwrite) BOOL displaySummary;
@property (nonatomic, retain) id selectedItem;
@property (nonatomic, readwrite) BOOL animateCell;

// Controls
@property (nonatomic, retain) ATPopupView* popupView;
@property (nonatomic, retain) UIRefreshControl* refreshControl;

// Delegate
//@property (nonatomic, assign) id <ATListViewDelegate> delegate;

// Control outlets
@property (strong, nonatomic) IBOutlet UITableView *tableView;

-(void) updateSummary;
-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller;
-(void) didFetch:(NSFetchedResultsController*)fetchedData;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@end
