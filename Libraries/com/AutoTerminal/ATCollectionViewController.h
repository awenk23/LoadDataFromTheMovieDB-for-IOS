//
//  ATCollectionViewController.h
//  IBCJapan
//
//  Created by i'Mac on 4/11/14.
//  Copyright (c) 2014 AutoTerminal. All rights reserved.
//

#import "ATViewController.h"
#import "ATPopupView.h"

@interface ATCollectionViewController : ATViewController

@property (nonatomic, retain) NSFetchedResultsController* fetchedData;

// Controls
@property (strong, retain) IBOutlet UICollectionView* collectionView;
@property (nonatomic, retain) ATPopupView* popupView;
@property (nonatomic, readwrite) BOOL animateCell;

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)performRefresh;

@end
