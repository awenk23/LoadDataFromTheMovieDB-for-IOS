//
//  ATGridView.h
//  IBCJapan
//
//  Created by i'Mac on 10/26/13.
//  Copyright (c) 2013 AutoTerminal. All rights reserved.
//

#import "ATViewController.h"
#import "AQGridView.h"
#import "ATPopupView.h"

@interface ATGridViewController : ATViewController

@property (nonatomic, retain) NSFetchedResultsController* fetchedData;

// Controls
@property (nonatomic, retain) AQGridView* gridView;
@property (nonatomic, retain) ATPopupView* popupView;

@end
