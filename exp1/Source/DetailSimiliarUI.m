//
//  DetailSimiliarUI.m
//  exp1
//
//  Created by imac on 02/06/18.
//  Copyright © 2018 paytren. All rights reserved.
//

#import "DetailSimiliarUI.h"
#import "IBCUserProxy.h"
#import "VONOWPLAYING.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "IBCAppFacade.h"
#import "VOMOVSIMILIAR.h"
#import "SimiliarColCell.h"

#define baseUrlImage @"https://image.tmdb.org/t/p/w500"

@interface DetailSimiliarUI ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSFetchedResultsController* _fetchedData;
}

@property (nonatomic,weak) IBOutlet UIImageView *imgPoster;
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UILabel *lblRelease;
@property (nonatomic,weak) IBOutlet UILabel *lblDesc;

@property (nonatomic,weak) IBOutlet UICollectionView * colView;

@end

@implementation DetailSimiliarUI

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.colView registerNib:[UINib nibWithNibName:@"SimiliarColCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    [self.navigationItem setTitle:_titleMov];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![self.facade hasMediator:self.mediatorName]) {
        [self.facade registerMediator:self];
    }
    [self setDetail];
    [self performRefresh];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.facade hasMediator:self.mediatorName]) {
        [self.facade removeMediator:self.mediatorName];
    }
}


#pragma mark - IMediator implementations
-(NSArray *)listNotificationInterests {
    
    return @[[IBCUserProxy SIMILIAR_SUCCESS]
             ];
    
}

-(void)handleNotification:(id<INotification>)notification {
    
    if ([[notification name] isEqualToString:[IBCUserProxy SIMILIAR_SUCCESS]]) {
        
        if ([notification body]) {
            [self performFetch];
        }
        
    }
    
    
}

#pragma mark - CollectionView delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return  1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _fetchedData.fetchedObjects.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellIdentifier = @"Cell";
    
    SimiliarColCell* cell = (SimiliarColCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if ( cell == nil ) {
        cell = [SimiliarColCell new];
    }
    
    [self configureCollectionCell:cell atIndexPath:indexPath];
    //    [self configureCollectionCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

#pragma mark - Private methods


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    VOMOVSIMILIAR *similiar=[_fetchedData objectAtIndexPath:indexPath];
    
    _idMov = similiar.id;
    _releaseDate = similiar.release_date;
    _posterPath = similiar.poster_path;
    _desc = similiar.overview;
    _titleMov = similiar.title;
    [self setDetail];
    [self performRefresh];
}


#pragma mark - CollectionView Layout delegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize itemSize = CGSizeMake(111, 166);
    
    return itemSize;
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0 ;
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 10;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

#pragma mark - private method
-(void)performRefresh{
    IBCUserProxy * proxy = (IBCUserProxy*)[self.facade retrieveProxy:[IBCUserProxy NAME]];
    [proxy getSimiliar:_idMov page:@"1"];
    
}

-(void)performFetch{
    IBCUserProxy * proxy = (IBCUserProxy*)[self.facade retrieveProxy:[IBCUserProxy NAME]];
    [self didFetch:[proxy dataSimiliar]];
}

-(void) didFetch:(NSFetchedResultsController *)fetchedData {
    
    _fetchedData = fetchedData;
    VOMOVSIMILIAR *similiar = [fetchedData.fetchedObjects objectAtIndex:0];
    
    
    [self.colView reloadData];
    
}

-(void)setDetail{
    self.navigationItem.title = _lblTitle.text= _titleMov;
    _lblRelease.text = _releaseDate;
    _lblDesc.text = _desc;
    
    
    NSString* urlImage = [NSString stringWithFormat:@"%@%@",baseUrlImage,_posterPath] ;
//    NSLog(@"%@",urlImage);
    [_imgPoster sd_setImageWithURL:[NSURL URLWithString:urlImage] placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageProgressiveDownload
                            progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    float progress = 0;
                                    if (expectedSize != 0) {
                                        progress = (float)receivedSize / (float)expectedSize;
                                    }
                                    //cell.loadingIndicator.progress = MAX(MIN(1, progress), 0);
                                });
                            }
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                               
                               if (!error) {
                                   
                                   [self->_imgPoster setImage:image];
                                   
                               } else {
                                   
                                   [self->_imgPoster setImage:[UIImage imageNamed:@"placeholder_unavailable_s.png"]];
                                   
                               }
                               
//                               cell.loadingIndicator.hidden = YES;
                               
                           }];
}

- (void)configureCollectionCell:(SimiliarColCell *)cell atIndexPath:(NSIndexPath*)indexPath {
    
    if ([cell.reuseIdentifier isEqualToString:@"Cell"]) {
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.usesGroupingSeparator = YES;
        numberFormatter.groupingSeparator = @".";
        numberFormatter.groupingSize = 3;
        
        
        VOMOVSIMILIAR* similiar= [_fetchedData objectAtIndexPath:indexPath];
        cell.lblTitle.text  = similiar.title;
        
        
        //        cell.loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
        //        cell.loadingIndicator.userInteractionEnabled = NO;
        CGPoint center= cell.imgCell.center;
        cell.loadingIndicator.center=center;
        //[cell addSubview:cell.loadingIndicator];
        
        cell.loadingIndicator.hidden = NO;
        cell.loadingIndicator.progress = 0;
        
        NSString* urlImage = [NSString stringWithFormat:@"%@%@",baseUrlImage,similiar.poster_path] ;
        //NSLog(@"%@",urlImage);
        [cell.imgCell sd_setImageWithURL:[NSURL URLWithString:urlImage] placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageProgressiveDownload
                                progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        float progress = 0;
                                        if (expectedSize != 0) {
                                            progress = (float)receivedSize / (float)expectedSize;
                                        }
                                        cell.loadingIndicator.progress = MAX(MIN(1, progress), 0);
                                    });
                                }
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                                   if (!error) {
                                       
                                       [cell.imgCell setImage:image];
                                       
                                   } else {
                                       
                                       [cell.imgCell setImage:[UIImage imageNamed:@"placeholder_unavailable_s.png"]];
                                       
                                   }
                                   
                                   cell.loadingIndicator.hidden = YES;
                                   
                               }];
        
        
        
    }
    
    
    
}

@end
