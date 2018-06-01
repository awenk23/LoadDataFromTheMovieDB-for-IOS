//
//  ATDatePickerView.h
//  IBCJapan
//
//  Created by i'Mac on 5/7/14.
//  Copyright (c) 2014 AutoTerminal. All rights reserved.
//

#import "ATViewController.h"

@class ATDatePickerView;

@protocol ATDatePickerViewDelegate <NSObject>

@optional

-(void) datePicker:(ATDatePickerView*) datePicker datePickerValueChanged:(NSDate *)date;

@end

@interface ATDatePickerView : ATViewController

// protocols
@property (nonatomic, assign) id <ATDatePickerViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end
