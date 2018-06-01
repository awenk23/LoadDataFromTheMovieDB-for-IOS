//
//  ATReorderableCollectionViewFlowLayout.m
//  IBCJapan
//
//  Created by i'Mac on 4/28/14.
//  Copyright (c) 2014 AutoTerminal. All rights reserved.
//

#import "ATReorderableCollectionViewFlowLayout.h"

@interface ATReorderableCollectionViewFlowLayout() {
 
    NSDictionary* _layoutInfo;
    UIEdgeInsets _itemInsets;
    CGSize _itemSize;
    CGFloat _spacingX;
    CGFloat _spacingY;
    
    NSInteger _colsPerPage;
    NSInteger _itemsPerPage;
    
}

@end

@implementation ATReorderableCollectionViewFlowLayout


#pragma mark - Layout

- (void)prepareLayout
{
    //NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    NSAssert(sectionCount <= 1, @"This layout does not support multiple sections");

    // required for iOS6, otherwise [super layoutAttributesForItemAtIndexPath] returns nil
    [super collectionViewContentSize];
    
    if (sectionCount == 1) {
        _itemSize = [[self delegate] collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        
        NSInteger rowsPerPage = self.collectionView.bounds.size.height / _itemSize.height;
        
        _colsPerPage = self.collectionView.bounds.size.width / _itemSize.width;
        _itemsPerPage = rowsPerPage * _colsPerPage;
        _itemInsets = UIEdgeInsetsZero;

        NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];

        _spacingX = [[self delegate] collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:indexPath.section];
        _spacingY = [[self delegate] collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:indexPath.section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:0];
            
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForItemAtIndexPath:indexPath];
            
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    //newLayoutInfo[@"0"] = cellLayoutInfo;
    
    _layoutInfo = cellLayoutInfo;
//    _itemInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//    _itemSize = CGSizeMake(340, 115);
//    _interItemSpacingY = 0;
    
}

#pragma mark - Private

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger page = indexPath.row / _itemsPerPage;
    NSInteger row = (indexPath.row % _itemsPerPage) / _colsPerPage;
    NSInteger column = (indexPath.row % _itemsPerPage) % _colsPerPage;
   
    /*CGFloat spacingX = self.collectionView.bounds.size.width -
    _itemInsets.left -
    _itemInsets.right -
    (_colsPerPage * itemSize.width);*/
    
    if (_colsPerPage > 1) _spacingX = _spacingX / (_colsPerPage - 1);
    
    CGFloat originX = (page * self.collectionView.bounds.size.width) + floorf(_itemInsets.left + (_itemSize.width + _spacingX) * column);
    
    CGFloat originY = floor(_itemInsets.top +
                            (_itemSize.height + _spacingY) * row);
    
    return CGRectMake(originX, originY, _itemSize.width, _itemSize.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:_layoutInfo.count];
    //[self collectionViewContentSize];
    [super layoutAttributesForElementsInRect:rect];
    
    [_layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                      UICollectionViewLayoutAttributes *attributes,
                                                      BOOL *innerStop) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            
            // get other attributes info from superclass
            // only use frame attributes from this subclass
            UICollectionViewLayoutAttributes* layoutAttribute =  [super layoutAttributesForItemAtIndexPath:indexPath];
            layoutAttribute.frame = [attributes frame];
            [allAttributes addObject:layoutAttribute];
            
        }
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{

    // get other attributes info from superclass
    // only use frame attribute from this subclass
    UICollectionViewLayoutAttributes* layoutAttribute =  [super layoutAttributesForItemAtIndexPath:indexPath];
    layoutAttribute.frame = [(UICollectionViewLayoutAttributes*)_layoutInfo[indexPath] frame];
    return layoutAttribute;
    
}


- (CGSize)collectionViewContentSize
{
    //NSInteger rowCount = [self.collectionView numberOfSections] / _numberOfColumns;
    //NSInteger rowsPerPage = self.collectionView.bounds.size.height / _itemSize.height;
    //NSInteger colsPerPage = self.collectionView.bounds.size.width / _itemSize.width;
    //NSInteger itemsPerPage = rowsPerPage * colsPerPage;
    
    // make sure we count another page if one is only partially filled.
    NSInteger page = 1;
    
    // if number of items match exactly the page content, do not add 1 page
    if ([self.collectionView numberOfSections] > 0) {
        if ([self.collectionView numberOfItemsInSection:0] % _itemsPerPage == 0) {
            page = 0;
        }
    }
    
    if ([self.collectionView numberOfSections] > 0) {
        page += [self.collectionView numberOfItemsInSection:0] / _itemsPerPage;
    }
    
    //NSLog(@"%@", NSStringFromCGSize(CGSizeMake(self.collectionView.bounds.size.width * page, self.collectionView.bounds.size.height)));
    return CGSizeMake(self.collectionView.bounds.size.width * page, self.collectionView.bounds.size.height);
}

@end
