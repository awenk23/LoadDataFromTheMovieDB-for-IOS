//
//  ATGridView.m
//  IBCJapan
//
//  Created by i'Mac on 10/26/13.
//  Copyright (c) 2013 AutoTerminal. All rights reserved.
//

#import "ATGridViewController.h"
#import "AQGridView.h"

@interface ATGridViewController () <NSFetchedResultsControllerDelegate, AQGridViewDataSource, AQGridViewDelegate>

@end


@implementation ATGridViewController

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
    // Do any additional setup after loading the view from its nib.
    
    // grid stuff
    self.gridView = [[AQGridView alloc] initWithFrame: CGRectZero];
    
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.gridView.autoresizesSubviews = YES;
    self.gridView.backgroundColor = [UIColor clearColor];
    self.gridView.opaque = NO;
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
    self.gridView.resizesCellWidthToFit = YES;
    self.gridView.usesPagedHorizontalScrolling = YES;
    self.gridView.pagingEnabled = YES;
    self.gridView.layoutDirection = AQGridViewLayoutDirectionHorizontal;
    self.gridView.showsHorizontalScrollIndicator = NO;
    self.gridView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.gridView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.fetchedData = nil;
}

- (void)viewDidUnload {
    
    self.gridView.delegate = nil;
    self.fetchedData.delegate = nil;
    
    [self setPopupView:nil];
    [self setFetchedData:nil];
    [self setGridView:nil];
    
    [super viewDidUnload];
}


#pragma mark - GridView Data Source
- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView {
    
    return self.fetchedData.fetchedObjects.count;
    
}

- (AQGridViewCell *) gridView: (AQGridView *) gridView cellForItemAtIndex: (NSUInteger) index {
    
    
    //static NSString * EmptyIdentifier = @"EmptyIdentifier";
    static NSString * cellIdentifier = @"CellIdentifier";
    /*
     if ( index == _emptyCellIndex ) {
     
     NSLog( @"Loading empty cell at index %u", index );
     AQGridViewCell * hiddenCell = [gridView dequeueReusableCellWithIdentifier: EmptyIdentifier];
     if ( hiddenCell == nil ) {
     
     // must be the SAME SIZE AS THE OTHERS
     // Yes, this is probably a bug. Sigh. Look at -[AQGridView fixCellsFromAnimation] to fix
     hiddenCell = [[AQGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 72.0, 72.0)
     reuseIdentifier: EmptyIdentifier];
     }
     
     hiddenCell.hidden = YES;
     return ( hiddenCell );
     }
     */
    
    AQGridViewCell * cell = [self.gridView dequeueReusableCellWithIdentifier: cellIdentifier];
    if ( cell == nil ) {
        cell = [[AQGridViewCell alloc] init];
    }
    
    [self configureCell:cell atIndex:index];
    
    //cell.icon = [_icons objectAtIndex: index];
    
    return cell;
}



#pragma mark - Fetched Result Controller delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.gridView beginUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    AQGridView* gridView = self.gridView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [gridView insertItemsAtIndices:[NSIndexSet indexSetWithIndex:indexPath.row] withAnimation:AQGridViewItemAnimationFade];
            
            break;
            
        case NSFetchedResultsChangeDelete:
            [gridView deleteItemsAtIndices:[NSIndexSet indexSetWithIndex:indexPath.row] withAnimation:AQGridViewItemAnimationFade];
            
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[gridView cellForItemAtIndex:indexPath.row] atIndex:indexPath.row];
            break;
            
        case NSFetchedResultsChangeMove:
            [gridView deleteItemsAtIndices:[NSIndexSet indexSetWithIndex:indexPath.row] withAnimation:AQGridViewItemAnimationFade];
            
            [gridView insertItemsAtIndices:[NSIndexSet indexSetWithIndex:indexPath.row] withAnimation:AQGridViewItemAnimationFade];
            
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.gridView endUpdates];
    [self.gridView reloadData];
    //[self configureDisplayItems:[[UIApplication sharedApplication] statusBarOrientation]];
    
}

- (void)configureCell:(AQGridViewCell *)cell atIndex:(NSInteger)index {
    
}

- (void)configureDisplayItems:(UIInterfaceOrientation) orientation {
    
}

@end
