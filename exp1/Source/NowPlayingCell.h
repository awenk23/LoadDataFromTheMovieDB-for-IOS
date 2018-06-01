//
//  NowPlayingCell.h
//  exp1
//
//  Created by imac on 01/06/18.
//  Copyright © 2018 paytren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DACircularProgressView.h"

@interface NowPlayingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgCell;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDscription;

@property (nonatomic, retain) DACircularProgressView* loadingIndicator;

@end
