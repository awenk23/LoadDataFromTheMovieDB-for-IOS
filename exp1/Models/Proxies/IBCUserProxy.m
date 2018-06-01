//
//  IBCUserProxy.m
//  AEMC
//
//  Created by i'Mac on 12/20/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "IBCUserProxy.h"
#import "Config.h"
#import "IBCAppFacade.h"

#import "VONOWPLAYING.h"
#import "VOMOVSIMILIAR.h"

// MVC Notifications
#define kMVCProxyName @"IBCUserProxy"
#define kMVCNowPlayingSucces @"IBCUserProxy/NowPlayingSucces"
#define kMVCSimiliarSucces @"IBCUserProxy/SimiliarSucces"

#define kMVCURLTMDB @"https://api.themoviedb.org/3/movie/"
//https://api.themoviedb.org/3/movie/9208/similar?api_key=0ae90ddc3f17c577fb1b09bbe966c828&language=en-US&page=1


// JSON Methods
#define kMVCURLMethodNowPlaying @"now_playing"
#define kMVCURLMethodSimiliar @"similar"

#define kMVCApiKey @"0ae90ddc3f17c577fb1b09bbe966c828"

@interface IBCUserProxy() {
    UserVO* _user;
}

@end

@implementation IBCUserProxy

-(void)initializeProxy {
	[super initializeProxy];
	self.proxyName = [IBCUserProxy NAME];
    _user = [[UserVO alloc] init];
    
    // set database name
    self.database = [IBCAppFacade getInstance].cacheData;
    
    // set entity name
//    self.entityName = @"PTHistoriTransferVO";
//
//    // set sort key(s)
//    self.sortKeys = @[@"tanggal"];
//    self.sortOrders = @[@NO];
//    self.sortDescriptors = ATCreateSortDescriptorsWithKeys(self.sortKeys, self.sortOrders);

    
}

#pragma mark - MVC Notification Constants
+(NSString *)NAME {
	return kMVCProxyName;
}

+(NSString *)NOWPLAYING_SUCCESS {
	return kMVCNowPlayingSucces ;
}

+(NSString *)SIMILIAR_SUCCESS {
	return kMVCSimiliarSucces ;
}




#pragma mark - Public methods
-(id) data {
    
    return _user;
    
}

-(id) dataNowPlaying {
    
    // set database name
    self.database = [IBCAppFacade getInstance].cacheData;
    
    self.entityName=@"VONOWPLAYING";
    self.predicateFormat = nil;
    self.predicateArguments = nil ;
    
    self.sortKeys = @[@"title"];
    self.sortOrders = @[@NO];
    self.sortDescriptors = ATCreateSortDescriptorsWithKeys(self.sortKeys, self.sortOrders);
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    [self fetchLocalData];
    //    });
    
    //[facade sendNotification:kMVCDataSuccess body:self.fetchedData];
    
    return self.fetchedData;
    
}

-(id) dataSimiliar {
    
    // set database name
    self.database = [IBCAppFacade getInstance].cacheData;
    
    self.entityName=@"VOMOVSIMILIAR";
    self.predicateFormat = nil;
    self.predicateArguments = nil ;
    
    self.sortKeys = @[@"title"];
    self.sortOrders = @[@NO];
    self.sortDescriptors = ATCreateSortDescriptorsWithKeys(self.sortKeys, self.sortOrders);
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    [self fetchLocalData];
    //    });
    
    //[facade sendNotification:kMVCDataSuccess body:self.fetchedData];
    
    return self.fetchedData;
    
}

-(void)getNowPlaying:(NSString*)page{
    
    NSString * param = [NSString stringWithFormat:@"%@%@?api_key=%@&language=en-US&page=%@",kMVCURLTMDB,kMVCURLMethodNowPlaying,kMVCApiKey,page];
    
    self.jsonRequest = [[ATJSONRequest alloc] init];
    self.jsonRequest.delegate = self;
    self.jsonRequest.input = @{ @"cmd" : kMVCURLMethodNowPlaying };
    [self.jsonRequest sendPHPRequestWithParameter:param methodName:kMVCURLMethodNowPlaying urlSelf:param];
    
}
     
-(void)getSimiliar:(NSString*)simId page:(NSString*)page{
    
    NSString * param = [NSString stringWithFormat:@"%@%@/%@?api_key=%@&language=en-US&page=%@",kMVCURLTMDB,simId,kMVCURLMethodSimiliar,kMVCApiKey,page];
    
    self.jsonRequest = [[ATJSONRequest alloc] init];
    self.jsonRequest.delegate = self;
    self.jsonRequest.input = @{ @"cmd" : kMVCURLMethodSimiliar };
    [self.jsonRequest sendPHPRequestWithParameter:param methodName:kMVCURLMethodSimiliar urlSelf:param];

    
}

#pragma mark - ATJSON delegate
-(void)jsonRequest:(ATJSONRequest *)jsonRequest didFinishWithData:(NSDictionary *)dictionary successful:(BOOL)successful {
    //NSLog(@"%@",dictionary);
    
    if ([[jsonRequest.input objectForKey:@"cmd"] isEqualToString:kMVCURLMethodNowPlaying]) {
            
            
            
            if (successful) {
                
                self.entityName=@"VONOWPLAYING";
                self.predicateFormat = nil;
                self.predicateArguments = nil ;
                NSMutableArray * dataarry = [NSMutableArray arrayWithCapacity:0];
                dataarry = [dictionary objectForKey:@"results"];
                
                NSLog(@"%@",dataarry);
                
                [self mergeData:dataarry
                 
                              insertBlock:^NSManagedObject *(NSManagedObjectContext *context) {
                                  VONOWPLAYING* newNowPlaying = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:context];
                                  
                                  return newNowPlaying;
                                  
                              }  keyBlock:^NSString *(NSDictionary *nowPlaying) {
                                  
                                  return [NSString stringWithFormat:@"%@", nowPlaying[@"id"]];
                                  
                              } sortDescriptors:ATCreateSortDescriptorsWithKeys(@[@"id"], nil)
                 
                 ];
                
                [facade sendNotification:kMVCNowPlayingSucces body:dictionary];
                return;
            }
                [facade sendNotification:kMVCNowPlayingSucces];
                
                
        }
        else  if ([[jsonRequest.input objectForKey:@"cmd"] isEqualToString:kMVCURLMethodSimiliar]) {
            NSLog(@"%@",dictionary);
                            
                if (successful) {
                    
                    self.entityName=@"VOMOVSIMILIAR";
                    self.predicateFormat = nil;
                    self.predicateArguments = nil ;
                    
                    NSMutableArray * dataarry = [NSMutableArray arrayWithCapacity:0];
                    dataarry = [dictionary objectForKey:@"results"];
                     
                     [self mergeDataWithUpdate:dataarry
                     
                     insertBlock:^NSManagedObject *(NSManagedObjectContext *context) {
                     VOMOVSIMILIAR* newSimiliar = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:context];
                     
                     return newSimiliar;
                     
                     } updateBlock:^(NSManagedObject *similiar, NSDictionary *dictionary, NSManagedObjectContext *context) {
                     VOMOVSIMILIAR* newSimiliar = (VOMOVSIMILIAR*)similiar;
//                         newSimiliar.page = [dictionary objectForKey:@"page"];
//                         newSimiliar.total_pages;
//                         newSimiliar.total_results;
                         
                         //result
                         newSimiliar.backdrop_path= [[dictionary objectForKey:@"backdrop_path"] isKindOfClass:[NSNull class]]?@"":[dictionary objectForKey:@"backdrop_path"];
                         newSimiliar.original_language= [[dictionary objectForKey:@"original_language"] isKindOfClass:[NSNull class]]?@"":[dictionary objectForKey:@"original_language"];;
                         newSimiliar.original_title= [[dictionary objectForKey:@"original_title"] isKindOfClass:[NSNull class]]?@"":[dictionary objectForKey:@"original_title"];;
                         newSimiliar.overview= [[dictionary objectForKey:@"overview"] isKindOfClass:[NSNull class]]?@"":[dictionary objectForKey:@"overview"];;
                         newSimiliar.release_date= [[dictionary objectForKey:@"release_date"] isKindOfClass:[NSNull class]]?@"":[dictionary objectForKey:@"release_date"];;
                         newSimiliar.poster_path= [[dictionary objectForKey:@"negaraDomisili"] isKindOfClass:[NSNull class]]?@"":[dictionary objectForKey:@"poster_path"];;
                         newSimiliar.title= [[dictionary objectForKey:@"title"] isKindOfClass:[NSNull class]]?@"":[dictionary objectForKey:@"title"];;
                     
                     
                     } keyBlock:^NSString *(NSDictionary *similiar) {
                     
                     return [NSString stringWithFormat:@"%@", similiar[@"id"]];
                     
                     } sortDescriptors:ATCreateSortDescriptorsWithKeys(@[@"id"], nil)
                     
                     ];
                    
                    [facade sendNotification:kMVCSimiliarSucces body:dictionary];
                    return;
                }
            [facade sendNotification:kMVCSimiliarSucces];
            }
        else {

            NSString* message = [NSString stringWithFormat:@"User ID and Password is incorrect"];
            
            //[[[UIAlertView alloc] initWithTitle:@"Login Fail" message: message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
    
    }
    
   
    


@end
