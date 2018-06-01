//
//  SimiliarColCell.h
//  exp1
//
//  Created by imac on 02/06/18.
//  Copyright © 2018 paytren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DACircularProgressView.h"

@interface SimiliarColCell : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UIImageView * imgCell;
@property (nonatomic,weak) IBOutlet UILabel * lblTitle;

@property (nonatomic, retain) DACircularProgressView* loadingIndicator;

@end
