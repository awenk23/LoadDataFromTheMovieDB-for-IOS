//
//  ATCustomCell.h
//  AEMC
//
//  Created by i'Mac on 10/5/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBadgedCell.h"
#import "HTAutocompleteTextField.h"

@class ATCustomCell;

@protocol ATCustomCellDelegate <NSObject>

@optional
-(void) customCell:(ATCustomCell*) cell segmentedControlValueChanged:(UISegmentedControl*)segmentedControl;

-(void) customCell:(ATCustomCell*) cell textFieldEditingDidBegin:(UITextField*)textField;
-(void) customCell:(ATCustomCell*) cell textFieldEditingDidEnd:(UITextField*)textField;
-(void) customCell:(ATCustomCell*) cell textFieldDidEndOnExit:(UITextField*)textField;
-(void) customCell:(ATCustomCell*) cell textFieldEditingChanged:(UITextField*)textField;
-(void) customCell:(ATCustomCell*) cell textViewEditingDidBegin:(UITextView*)textView;
-(void) customCell:(ATCustomCell*) cell textViewEditingDidEnd:(UITextView*)textView;
-(void) customCell:(ATCustomCell*) cell buttonTouchUpInside:(UIButton *)button;
-(void) customCell:(ATCustomCell*) cell datePickerValueChanged:(UIDatePicker *)datePicker;

-(void) customCell:(ATCustomCell *)cell switchValueChanged:(UISwitch*)switchButton;

@end

@protocol ATCustomCellDataSource <NSObject>

@optional
-(NSString*) customCell:(ATCustomCell*) cell titleAtButtonIndex:(NSInteger)index;
-(NSString*)textField:(HTAutocompleteTextField*)textField completionForPrefix:(NSString*)prefix ignoreCase:(BOOL)ignoreCase;

@end

@interface ATCustomCell : TDBadgedCell

// protocols
@property (nonatomic, assign) id <ATCustomCellDelegate> delegate;
@property (nonatomic, assign) id <ATCustomCellDataSource> dataSource;

//@property (weak, nonatomic)  UILabel *label;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedToggle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;

// public properties
@property (nonatomic, assign) NSString* cellType;
@property (nonatomic, readwrite) BOOL enabled;

//- (void) setCheckmark:(BOOL)enabled;
//- (void) setButtonColor;
- (void) configure:(id)managedObject;

@end
