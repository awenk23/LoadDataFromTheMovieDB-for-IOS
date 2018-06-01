//
//  ATListViewController.m
//  AEMC
//
//  Created by i'Mac on 10/5/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "ATListViewController.h"
#import "AppDelegate.h"
#import "ATGlobal.h"
#import "TDBadgedCell.h"

@interface ATListViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
    NSPredicate* _originalPredicate;
}

@end

@implementation ATListViewController

@synthesize popupView = _popupView;
@synthesize displaySummary = _displaySummary;

- (void)viewDidLoad
{
    [super viewDidLoad];

    _displaySummary = NO;
    
    // set general style
    //UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    //cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if (!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        }
    
    UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped:)];
    
    _animateCell = YES;
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    // Add refresh control
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    _originalPredicate = nil;
    
    [self setFetchedData:nil];
    [self setTableView:nil];
    [self setPopupView:nil];
    
    [super viewDidUnload];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table View data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = [[_fetchedData sections] count];
    
    // if display summary and has results
    if (_displaySummary && _fetchedData.fetchedObjects.count > 0) {
        sectionCount++;
    }
    
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    
    if (section < _fetchedData.sections.count) {
        rowCount = [[[_fetchedData sections] objectAtIndex:section] numberOfObjects];
    }
    
    if (_displaySummary && section == _fetchedData.sections.count) {
        rowCount = 1;
    }
    
    return rowCount;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title;
    
    // Return section title
    if (section < _fetchedData.sections.count) {
        title = [[[_fetchedData sections] objectAtIndex:section] name];
        if ([title isEqualToString:@"*"]) title = kATFavoriteSign;
    }
    
    return title;
}


- (NSArray*) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
    if (tableView != self.tableView) {
        return nil;
    }
    
    NSMutableArray* index;
    
    // display section index only if (1) section key is not nill (2) result count is > 20 (3) table style is plain
    if (self.fetchedData.sectionNameKeyPath && self.tableView.style == UITableViewStylePlain && [_fetchedData.sections count] > 10) {
        index = [NSMutableArray arrayWithArray:[_fetchedData sectionIndexTitles]];
        
        // the ★ symbol is not showing on indexTitles for some reason, have to replace it here
        NSString* symbol = [index objectAtIndex:0];
        if ([symbol isEqualToString:@"*"]) {
            [index setObject:kATFavoriteSign atIndexedSubscript:0];
        }
        
        [index insertObject:UITableViewIndexSearch atIndex:0];
    }
    
    return  index;
}


- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger sectionIndex;
    
    if (index == 0) {
        [self.tableView scrollRectToVisible:[[self.tableView tableHeaderView] bounds] animated:NO];
        sectionIndex = -1;
    } else {
        
        if ([title isEqualToString:kATFavoriteSign]) title = @"*";
        
        sectionIndex = [_fetchedData sectionForSectionIndexTitle:title atIndex:index - 1];
    }
    
    return sectionIndex;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* identifier = @"Cell";
    
    if (indexPath.section == _fetchedData.sections.count && _displaySummary) {
        identifier = @"Summary";
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Return cell height
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    return (cell) ? cell.frame.size.height : self.tableView.rowHeight;

}

#pragma mark - Fetched Result Controller delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    if (!_animateCell) return;

    [self.tableView beginUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    if (!_animateCell) return;
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if (!_animateCell) return;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
            
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if (!_animateCell) return;
    
    if (_displaySummary) {
        // insert summary section when records are fetched
        if (_fetchedData.sections.count == self.tableView.numberOfSections) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.fetchedData.sections.count] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        // delete summary section if no record are fetched
        if (self.tableView.numberOfSections - _fetchedData.sections.count == 1 && _fetchedData.fetchedObjects.count == 0) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:self.fetchedData.sections.count] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


#pragma mark - Search display delegate
- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    if ([self.fetchedData.fetchedObjects count] == 0) {
        return NO;
    }
    
    // blank string
    if ([searchString isEqualToString:@""]) {
        [self searchBarCancelButtonClicked:self.searchDisplayController.searchBar];
        
    } else {
        
        NSFetchRequest* fetchRequest = [_fetchedData fetchRequest];
        
        NSPredicate* searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString];
        
        [fetchRequest setPredicate:searchPredicate];
        
        NSError* error;
        BOOL success = [_fetchedData performFetch:&error];
        if (!success) {
            // Handle the error.
        }
        
    }

    return YES;
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSFetchRequest* fetchRequest = [_fetchedData fetchRequest];
    
    if (_originalPredicate != nil) {
        [fetchRequest setPredicate:_originalPredicate];
    }
    
    NSError* error;
    BOOL success = [_fetchedData performFetch:&error];
    if (!success) {
        // Handle the error.
    }
    
}

#pragma mark - Refresh Control delegates
- (void)refreshControlValueChanged:(UIRefreshControl*) sender {
    
    [self performRefresh];
    [sender endRefreshing];
    
}

#pragma mark - Private methods
- (void) didFetch:(NSFetchedResultsController*)fetchedData {
    
    // clear NFC
    if (self.fetchedData) {
        self.fetchedData.delegate = nil;
        self.fetchedData = nil;
    }
    
}

- (void) performRefresh {
    // Handle implementation in the subclass
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Handle implementation in the subclass
    
}

#pragma mark - Public methods
-(void) updateSummary {
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:_fetchedData.sections.count] withRowAnimation:UITableViewRowAnimationFade];

}

@end
