//
//  ATCollectionViewController.m
//  IBCJapan
//
//  Created by i'Mac on 4/11/14.
//  Copyright (c) 2014 AutoTerminal. All rights reserved.
//

#import "ATCollectionViewController.h"

@interface ATCollectionViewController ()  <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate> {
    
    NSMutableArray* _sectionChanges;
    NSMutableArray* _objectChanges;
    
}

@end

@implementation ATCollectionViewController

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
    //self.collectionView = [[UICollectionView alloc] initWithFrame: CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
    
    //self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    //self.collectionView.autoresizesSubviews = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.opaque = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    //self.collectionView.resizesCellWidthToFit = YES;
    //self.collectionView.usesPagedHorizontalScrolling = YES;
    //self.collectionView.pagingEnabled = YES;
    //self.collectionView.layoutDirection = AQcollectionViewLayoutDirectionHorizontal;
    //self.collectionView.showsHorizontalScrollIndicator = NO;
    //self.collectionView.showsVerticalScrollIndicator = NO;
    //[self.view addSubview:self.collectionView];
    
    _objectChanges = [NSMutableArray arrayWithCapacity:10];
    _sectionChanges = [NSMutableArray arrayWithCapacity:1];
    _animateCell = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.fetchedData = nil;
}

- (void)viewDidUnload {
    
    self.collectionView.delegate = nil;
    self.fetchedData.delegate = nil;
    
    [self setPopupView:nil];
    [self setFetchedData:nil];
    [self setCollectionView:nil];
    
    [super viewDidUnload];
}


#pragma mark - CollectionView Data Source
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    NSInteger sectionCount = [[_fetchedData sections] count];
    
    // if display summary and has results
    //if (_displaySummary && _fetchedData.fetchedObjects.count > 0) {
    //    sectionCount++;
    //}
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    return sectionCount;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    NSInteger rowCount = 0;
    
    if (section < _fetchedData.sections.count) {
        rowCount = [[[_fetchedData sections] objectAtIndex:section] numberOfObjects];
    }
    
    //if (_displaySummary && section == _fetchedData.sections.count) {
    //    rowCount = 1;
    //}
    
    return rowCount;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString * cellIdentifier = @"CellIdentifier";

    UICollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    if ( cell == nil ) {
        cell = [UICollectionViewCell new];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    //cell.icon = [_icons objectAtIndex: index];
    
    return cell;

    
}

#pragma mark - NSFetchedResultsController Delegates
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @[@(sectionIndex)];
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @[@(sectionIndex)];
            break;
        default:
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    if (!self.animateCell) {
        [_sectionChanges removeAllObjects];
        [_objectChanges removeAllObjects];
        return;
    }
    
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        default:
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _objectChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
                
            }
            
        } completion:^(BOOL finished) {
            [self.collectionView.collectionViewLayout invalidateLayout];
        }];
        
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

#pragma mark - Private methods
- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath*)indexPath {
    
}

- (void)configureDisplayItems:(UIInterfaceOrientation) orientation {
    
}

-(void) performRefresh {
    
    // if loading in progress, do nothing
    if (self.popupView.isRunning) return;
    
    // display loading message
    
    CGPoint center = self.view.center;
    center.y += 10;
    self.popupView = [[ATPopupView alloc] initWithCenter:center text:@"Loading ..."];
    [self.view addSubview:self.popupView];
    
    
    // fetch remotely
    // implement this in the subclass
    
}

@end
