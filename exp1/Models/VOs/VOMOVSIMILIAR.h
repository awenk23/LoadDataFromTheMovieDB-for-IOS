//
//  VOMOVSIMILIAR.h
//  exp1
//
//  Created by imac on 29/05/18.
//  Copyright © 2018 paytren. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface VOMOVSIMILIAR : NSManagedObject

@property(nonatomic,retain) NSNumber * page;
@property(nonatomic,retain) NSNumber * total_pages;
@property(nonatomic,retain) NSNumber * total_results;

//result
@property(nonatomic,retain) NSString * adult;
@property(nonatomic,retain) NSString * backdrop_path;
@property(nonatomic,retain) NSString * id;
@property(nonatomic,retain) NSString * original_language;
@property(nonatomic,retain) NSString * original_title;
@property(nonatomic,retain) NSString * overview;
@property(nonatomic,retain) NSString * release_date;
@property(nonatomic,retain) NSString * poster_path;
@property(nonatomic,retain) NSString * popularity;
@property(nonatomic,retain) NSString * title;
@property(nonatomic,retain) NSNumber * video;
@property(nonatomic,retain) NSString * vote_average;
@property(nonatomic,retain) NSString * vote_count;

@end
