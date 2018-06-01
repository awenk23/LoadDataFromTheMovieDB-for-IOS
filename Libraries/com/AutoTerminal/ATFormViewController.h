//
//  ATFormViewController.h
//  AEMC
//
//  Created by i'Mac on 10/12/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATJSONRequest.h"
#import "ATPopupView.h"
#import "ATCustomCell.h"
#import "ATViewController.h"

@interface ATFormViewController : ATViewController <UITableViewDataSource, UITableViewDelegate, ATJSONRequestDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) ATPopupView* popupView;
@property (nonatomic, retain) ATJSONRequest* jsonRequest;

- (void) setCellVisibilityWithIdentifier:(NSArray*) identifiers hidden:(BOOL)hidden animated:(BOOL)animated;
- (void) setCellVisibilityWithIdentifier:(NSArray*) identifiers hidden:(BOOL)hidden;

- (void) setSectionVisibilityWithIndexSet:(NSIndexSet*) indexSet hidden:(BOOL)hidden;
- (NSIndexPath*) getIndexPathFromCellIdentifier:(NSString*) identifier;
- (NSIndexPath*) getIndexPathFromCellIdentifier:(NSString*) identifier visibleOnly:(BOOL)visibleOnly;
- (UITableViewCell*)getPrototypeCellFromTableView:(UITableView*)tableView identifier:(NSString *)identifier;
- (void) configureCell:(ATCustomCell*)cell;
- (void) initializeFormWithFile:(NSString*)filename;

- (NSDictionary*) getCellInfoWithIndexPath:(NSIndexPath*)indexPath;
- (NSArray*) getVisibleCellArrayAtSection:(NSInteger) section;
- (ATCustomCell*)getPrototypeCellFromTableView:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath;

@end
