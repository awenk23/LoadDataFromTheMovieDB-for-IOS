//
//  ATDatePickerView.m
//  IBCJapan
//
//  Created by i'Mac on 5/7/14.
//  Copyright (c) 2014 AutoTerminal. All rights reserved.
//

#import "ATDatePickerView.h"

@interface ATDatePickerView ()

@end

@implementation ATDatePickerView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // resize date picker (for iOS6) because Date Picker can't be resized in Interface Builder
    CGRect frame = self.datePicker.frame;
    frame.origin.y -= 20;
    frame.size.height = 216;
    self.datePicker.frame = frame;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)datePickerValueChanged:(id)sender {

    if ([self.delegate respondsToSelector:@selector(datePicker:datePickerValueChanged:)]) {
        [self.delegate datePicker:self datePickerValueChanged:self.datePicker.date];
    }
    
}

@end
