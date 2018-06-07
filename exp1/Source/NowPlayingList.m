//
//  NowPlayingList.m
//  exp1
//
//  Created by imac on 01/06/18.
//  Copyright © 2018 paytren. All rights reserved.
//

#import "NowPlayingList.h"
#import "IBCUserProxy.h"
#import "VONOWPLAYING.h"
#import "NowPlayingCell.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "IBCAppFacade.h"
#import "DetailSimiliarUI.h"
#import "UserVO.h"

#define baseUrlImage @"https://image.tmdb.org/t/p/w500"
@interface NowPlayingList ()<UITableViewDelegate,UITableViewDataSource>
{
    NSFetchedResultsController* _fetchedData;
}
@end

@implementation NowPlayingList

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:@"NowPlayingCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.navigationItem.title = @"Now Playing List" ;
     UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadData:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    
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
    [self performFetch];
    if(_fetchedData.fetchedObjects.count==0){
        IBCUserProxy * proxy = (IBCUserProxy*)[facade retrieveProxy:[IBCUserProxy NAME]];
        UserVO * user =  [proxy data];
        user.pageCurrent = @0;
        [self performRefresh];
    }

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.facade hasMediator:self.mediatorName]) {
        [self.facade removeMediator:self.mediatorName];
    }
}

#pragma mark - IMediator implementations
-(NSArray *)listNotificationInterests {
    
    return @[[IBCUserProxy NOWPLAYING_SUCCESS]
             ];
    
}

-(void)handleNotification:(id<INotification>)notification {
    
    if ([[notification name] isEqualToString:[IBCUserProxy NOWPLAYING_SUCCESS]]) {
        if (self.popupView) {
            [self.popupView remove];
        }
        
        if ([notification body]) {
            [self performFetch];
        }
        
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[[_fetchedData sections] objectAtIndex:section] numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NowPlayingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    VONOWPLAYING *nowPlaying = [_fetchedData objectAtIndexPath:indexPath];
    //cell.imgCell = nowPlaying.poster_path;
    CGPoint center= cell.imgCell.center;
    cell.loadingIndicator.center=center;
    //[cell addSubview:cell.loadingIndicator];
    
    cell.loadingIndicator.hidden = NO;
    cell.loadingIndicator.progress = 0;
   
    NSString* urlImage = [NSString stringWithFormat:@"%@%@",baseUrlImage,nowPlaying.poster_path] ;
//    NSLog(@"%@",urlImage);
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
    
    
    cell.lblTitle.text = nowPlaying.original_title;
    cell.lblDscription.text = nowPlaying.overview;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IBCUserProxy *proxy=(IBCUserProxy*)[facade retrieveProxy:[IBCUserProxy NAME]];
    //VONOWPLAYING *nowPlaying=[proxy dataNowPlaying];
    
    NowPlayingCell* cell = (NowPlayingCell*)[tableView cellForRowAtIndexPath:indexPath];
    VONOWPLAYING* nowPlaying = [_fetchedData objectAtIndexPath:indexPath];
    
    DetailSimiliarUI *similiarUI = [DetailSimiliarUI new];
    similiarUI.title = nowPlaying.original_title;
    similiarUI.releaseDate = nowPlaying.release_date;
    similiarUI.desc = nowPlaying.overview;
    similiarUI.posterPath = nowPlaying.poster_path;
    similiarUI.idMov = nowPlaying.id;
    
    [self.navigationController pushViewController:similiarUI animated:YES];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Need to call the service & update the array
    if(indexPath.row + 1 == _fetchedData.fetchedObjects.count) {
        
        [self loadMore];
    }
}


#pragma mark - private method
-(void)performRefresh{
    
    IBCUserProxy * proxy = (IBCUserProxy*)[self.facade retrieveProxy:[IBCUserProxy NAME]];
    UserVO * user = [proxy data];
    user.pageCurrent = @0;
    [self loadMore];
}

-(void)loadMore{
    
    if (self.popupView.isRunning) return;
    self.popupView = [[ATPopupView alloc] initWithCenter:self.view.center text:@"Loading..."];
    [self.view addSubview:self.popupView];
    
    IBCUserProxy * proxy = (IBCUserProxy*)[self.facade retrieveProxy:[IBCUserProxy NAME]];
    UserVO * user = [proxy data];
    int pageToLoad = [user.pageCurrent intValue]==0?1:[user.pageCurrent intValue]+1;
    [proxy getNowPlaying:[NSString stringWithFormat:@"%d",pageToLoad]];
}

-(void)performFetch{
    IBCUserProxy * proxy = (IBCUserProxy*)[self.facade retrieveProxy:[IBCUserProxy NAME]];
    [self didFetch:[proxy dataNowPlaying]];
}

-(void) didFetch:(NSFetchedResultsController *)fetchedData {
    
    _fetchedData = fetchedData;
    //VONOWPLAYING *nowPlaying = [fetchedData.fetchedObjects objectAtIndex:0];
    
    [self.tableView reloadData];
    
}

- (IBAction)reloadData:(id)sender
{
    // do something or handle Search Button Action.
    [self performRefresh];
    
}

@end
