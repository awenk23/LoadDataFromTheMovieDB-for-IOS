//
//  ATTableFormViewController.m
//  AEMC
//
//  Created by i'Mac on 10/12/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "ATFormViewController.h"


@interface ATFormViewController () <ATCustomCellDataSource>
{
    NSMutableArray* _sectionArray;
    NSMutableArray* _visibleSectionArray;
    NSString * _filename;
}

@end

@implementation ATFormViewController

@synthesize popupView = _popupView;

#pragma mark - View Delegates
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //self.tableView.separatorColor = [UIColor clearColor];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _jsonRequest.delegate = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setJsonRequest:nil];
    _sectionArray = nil;
    _visibleSectionArray = nil;
    _popupView = nil;
    [self setTableView:nil];
    [super viewDidUnload];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _visibleSectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self getVisibleCellArrayAtSection:section].count;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Return section title
    NSDictionary* sectionInfo = [_visibleSectionArray objectAtIndex:section];
    return (NSString*)[sectionInfo objectForKey:@"Title"];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return cell content
    ATCustomCell* cell = (ATCustomCell*)[self getPrototypeCellFromTableView:tableView indexPath:indexPath];
    
    [self configureCell:cell];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return cell height
    UITableViewCell *cell = [self getPrototypeCellFromTableView:tableView indexPath:indexPath];

    return cell.frame.size.height;//, [self heightForBasicCellAtIndexPath:indexPath]);

}

#pragma mark - Table view delegate
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //if (tableView.style != UITableViewStyleGrouped) return;
    
    UIView* sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    
    UILabel* sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 10, sectionView.frame.size.width, sectionView.frame.size.height)];
    
    sectionLabel.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    sectionLabel.textColor = kATLightGrayTint;
    sectionLabel.backgroundColor = [UIColor clearColor];
    sectionLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    
    [sectionView addSubview:sectionLabel];
    
    return sectionView;
}

#pragma mark - AT Cell data source
- (NSString *)customCell:(ATCustomCell *)cell titleAtButtonIndex:(NSInteger)index {
    
    NSDictionary* cellInfo = [self getCellInfoWithIndexPath:[self getIndexPathFromCellIdentifier:cell.reuseIdentifier]];
    NSArray* buttons = [cellInfo objectForKey:@"Buttons"];
    
    return [buttons objectAtIndex:index];
}

#pragma mark - Helper functions
- (UITableViewCell*)getPrototypeCellFromTableView:(UITableView*)tableView identifier:(NSString *)identifier
{
    return [self getPrototypeCellFromTableView:tableView indexPath:[self getIndexPathFromCellIdentifier:identifier visibleOnly:YES]];
}

- (ATCustomCell*)getPrototypeCellFromTableView:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    NSArray* cellArray = [self getVisibleCellArrayAtSection:indexPath.section];
    NSString* cellIdentifier  = [[cellArray objectAtIndex:indexPath.row] objectForKey:@"Identifier"];
    
    ATCustomCell* prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    return prototypeCell;
}

- (void) configureCell:(ATCustomCell*)cell
{
    
    NSDictionary* cellInfo = [self getCellInfoWithIndexPath:[self getIndexPathFromCellIdentifier:cell.reuseIdentifier]];

    cell.titleLabel.text = cellInfo[@"Title"];
    cell.cellType = cellInfo[@"Type"];
    
    if (cellInfo[@"Placeholder"]) {
        cell.textField.placeholder = cellInfo[@"Placeholder"];
    }

    if (cellInfo[@"Subtitle"]) {
        cell.detailLabel.text = cellInfo[@"Subtitle"];
    } else {
        cell.detailLabel.text = nil;
    }

    // additional setup for segmented control
    if ([cell.cellType isEqualToString:@"SegmentedControl"] ||
        [cell.cellType isEqualToString:@"SegmentedToggle"]) {
        
        // clear segments
        [cell.segmentedControl removeAllSegments];
        if ([cell.cellType isEqualToString:@"SegmentedToggle"]) {
            [cell.segmentedToggle removeAllSegments];
        }
        
        // insert segments
        NSArray* buttons = cellInfo[@"Buttons"];
        
        [buttons enumerateObjectsUsingBlock:^(NSString* title, NSUInteger idx, BOOL *stop) {
            [cell.segmentedControl insertSegmentWithTitle:title atIndex:idx animated:NO];
            
            if ([cell.cellType isEqualToString:@"SegmentedToggle"]) {
                [cell.segmentedToggle insertSegmentWithTitle:title atIndex:idx animated:NO];
            }
        }];
        
        cell.dataSource = self;
    }
    
    [cell.titleLabel sizeToFit];
}

- (void) setVisibleSectionArray
{
    // set visible section array
    
    // init or reset array
    if (_visibleSectionArray == nil) {
        _visibleSectionArray = [[NSMutableArray alloc] init];
    } else {
        [_visibleSectionArray removeAllObjects];
    }
    
    // loop and update array
    for (NSDictionary* section in _sectionArray) {
        BOOL hidden = [[section objectForKey:@"Hidden"] boolValue];
        if (! hidden) [_visibleSectionArray addObject:section];
    }
    
    //return visibleSectionArray;
}

- (void) setSectionVisibilityWithIndexSet:(NSIndexSet*) indexSet hidden:(BOOL)hidden
{
    
    BOOL found = NO;
    
    NSUInteger currentIndex = [indexSet firstIndex];
    while (currentIndex != NSNotFound)
    {
        //use the currentIndex
        NSDictionary* sectionInfo = [_sectionArray objectAtIndex:currentIndex];
        
        BOOL sectionHidden = [[sectionInfo objectForKey:@"Hidden"] boolValue];
        
        if (sectionHidden != hidden) {
            [sectionInfo setValue:[NSNumber numberWithBool:hidden] forKey:@"Hidden"];
            found = YES;
        }
        
        //increment
        currentIndex = [indexSet indexGreaterThanIndex: currentIndex];
    }
    
    // update visible section array
    [self setVisibleSectionArray];
    
    // perform delete/insert only when found
    if (found) {
        if (hidden) {
            [self.tableView deleteSections:indexSet withRowAnimation:(UITableViewRowAnimationAutomatic)];
        } else {
            [self.tableView insertSections:indexSet withRowAnimation:(UITableViewRowAnimationAutomatic)];
        }
    }
    
}

- (NSArray*) getVisibleCellArrayAtSection:(NSInteger) section
{
    
    // get visible cell array
    NSDictionary* sectionInfo = [_visibleSectionArray objectAtIndex:section];
    NSMutableArray* visibleCellArray = [[NSMutableArray alloc] init];
    
    NSArray* cells = [sectionInfo objectForKey:@"Cells"];
    
    [cells enumerateObjectsUsingBlock:^(id cell, NSUInteger idx, BOOL *stop) {
        BOOL hidden = [[cell objectForKey:@"Hidden"] boolValue];
        if (! hidden) [visibleCellArray addObject:cell];
    }];
    
    return visibleCellArray;
}

- (NSIndexPath*) getIndexPathFromCellIdentifier:(NSString*) identifier
{
    return [self getIndexPathFromCellIdentifier:identifier visibleOnly:YES];
}

- (NSIndexPath*) getIndexPathFromCellIdentifier:(NSString*) identifier visibleOnly:(BOOL)visibleOnly
{
    // function to loop through section array to construct the index path
    
    NSDictionary* sectionInfo;
    NSDictionary* cellInfo;
    NSArray* cellArray;
    NSInteger section = 0;
    NSInteger index = 0;
    BOOL found = NO;
    //NSInteger hiddenCount = 0;
    
    // loop through each section
    for (section = 0; section < _visibleSectionArray.count; section++) {
        
        sectionInfo = [_visibleSectionArray objectAtIndex:section];
        cellArray = [sectionInfo objectForKey:@"Cells"];
        
        if (visibleOnly) {
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"Hidden = NO"];
            cellArray = [cellArray filteredArrayUsingPredicate:predicate];
        }
        
        // loop through each row
        for (index = 0; index < cellArray.count; index++) {
            
            cellInfo = [cellArray objectAtIndex:index];
            
            if ([(NSString*)[cellInfo objectForKey:@"Identifier"] isEqualToString:identifier]) {
                found = YES;
                break;
            }
            
            /*if (visibleOnly && [[cellInfo objectForKey:@"Hidden"] boolValue]) {
             hiddenCount ++;
             }*/
            
        }
        
        if (found) break;
    }
    
    if (!found) {
        return nil;
    }
    
    return [NSIndexPath indexPathForRow:index inSection:section];
    
}

- (void) setCellVisibilityWithIdentifier:(NSArray*) identifiers hidden:(BOOL)hidden {
    
    // default animated
    [self setCellVisibilityWithIdentifier:identifiers hidden:hidden animated:YES];
    
}

- (void) setCellVisibilityWithIdentifier:(NSArray*) identifiers hidden:(BOOL)hidden animated:(BOOL)animated {
    
    // hide/display cell based on cell identifiers
    NSMutableArray* indexPaths = [NSMutableArray arrayWithCapacity:identifiers.count];
    NSInteger i = 0;
    NSInteger row = 0;
    
    // construct array of index paths
    for (NSString* identifier in identifiers) {
        NSIndexPath* indexPath = [self getIndexPathFromCellIdentifier:identifier visibleOnly:NO];
        
        NSDictionary* sectionInfo = [_visibleSectionArray objectAtIndex:indexPath.section];
        NSArray* cells = [sectionInfo objectForKey:@"Cells"];

        for (; i < cells.count; i++) {
            
            NSDictionary* cell = [cells objectAtIndex:i];
            
            if ([[cell objectForKey:@"Identifier"] isEqualToString:identifier]) {
            
                if ([[cell objectForKey:@"Hidden"] boolValue] != hidden) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:indexPath.section]];
                }
                
                if ([[cell objectForKey:@"Hidden"] boolValue]) {
                    row++;
                }
                
                break;
            }
            
            if (![[cell objectForKey:@"Hidden"] boolValue]) {
                row++;
            }
            
        }
    }

    
    for (NSString* identifier in identifiers) {
        NSIndexPath* indexPath = [self getIndexPathFromCellIdentifier:identifier visibleOnly:NO];
        
        NSDictionary* sectionInfo = [_visibleSectionArray objectAtIndex:indexPath.section];
        NSArray* cells = [sectionInfo objectForKey:@"Cells"];
        NSDictionary* cellInfo = [cells objectAtIndex:indexPath.row];
        
        BOOL cellHidden = [[cellInfo objectForKey:@"Hidden"] boolValue];
        
        if (cellHidden != hidden && indexPath) {
            [cellInfo setValue:[NSNumber numberWithBool:hidden] forKey:@"Hidden"];
        }
    }
    
    // insert/delete row from tableview
    if (indexPaths.count > 0) {
        if (animated) {
            if (hidden) {
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation: UITableViewRowAnimationMiddle];
            } else {
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation: UITableViewRowAnimationMiddle];
            }

        } else {
            
            [self.tableView reloadData];
            
        }
        
    }
    
}

- (void) registerCellPrototypes {
    
    // loop through sections
    [_sectionArray enumerateObjectsUsingBlock:^(NSDictionary* sectionInfo, NSUInteger idx, BOOL *stop) {
        
        NSArray* cells = [sectionInfo objectForKey:@"Cells"];
        
        // loop through cells
        [cells enumerateObjectsUsingBlock:^(NSDictionary* cellInfo, NSUInteger idx, BOOL *stop) {
            
            // construct nib name
            NSString* cellNibName = [NSString stringWithFormat:@"AT%@Cell", [cellInfo objectForKey:@"Type"]];
            
            // register cell
            [self.tableView registerNib:[UINib nibWithNibName:cellNibName bundle:nil]   forCellReuseIdentifier:[cellInfo objectForKey:@"Identifier"]];
            
        }];
        
    }];
}

- (NSDictionary*) getCellInfoWithIndexPath:(NSIndexPath*)indexPath {
    
    NSArray* cells = [self getVisibleCellArrayAtSection:indexPath.section];
    
    return [cells objectAtIndex:indexPath.row];
    
}

- (void) initializeFormWithFile:(NSString*)filename {
    
    // Load Table Definitions
    NSString* path = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
    _sectionArray = [NSMutableArray arrayWithContentsOfFile:path];
    _filename=filename;
        //NSLog(@"%@",[_sectionArray objectAtIndex:1]);
    // Register Cell Prototypes
    [self registerCellPrototypes];
    
    // Set Visible Section Array
    [self setVisibleSectionArray];
    
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static ATCustomCell *cell = nil;
    static dispatch_once_t onceToken;
    
    NSDictionary* cellInfo = [self getCellInfoWithIndexPath:indexPath];
    
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:[cellInfo objectForKey:@"Identifier"]];
    });
    
    [self configureCell:cell];
    //[self configureBasicCell:sizingCell atIndexPath:indexPath];
    //[cell configure:[self.fetchedData objectAtIndexPath:indexPath]];
    return [self calculateHeightForConfiguredSizingCell:cell];
}


- (CGFloat)calculateHeightForConfiguredSizingCell:(ATCustomCell *)cell {
    //[cell setNeedsUpdateConstraints];
    //[cell updateConstraintsIfNeeded];
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    //NSLog(@"%@ %@", NSStringFromCGRect(cell.labelDescription.frame), cell.labelDescription.text);
    //NSLog(@"%@", NSStringFromCGSize(size));
    
    return size.height + 1.0f;
}

@end
