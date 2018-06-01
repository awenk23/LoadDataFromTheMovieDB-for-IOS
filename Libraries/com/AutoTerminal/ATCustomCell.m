//
//  ATCustomCell.m
//  AEMC
//
//  Created by i'Mac on 10/5/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "ATCustomCell.h"
#import "ATGlobal.h"

@interface ATCustomCell() <UITextViewDelegate>

@end

@implementation ATCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;

}

- (void) awakeFromNib {
    
    // Set control color
    //[self.segmentedControl setTintColor:kATLightGrayTint];
    //self.detailTextLabel.textColor = kATColorRed;
    //self.textField.textColor = kATColorRed;
    
    // Set keyboard transparent
    //[self.textField setKeyboardAppearance:UIKeyboardAppearanceAlert];
    //[self.textView setKeyboardAppearance:UIKeyboardAppearanceAlert];
    /*
    // Create hidden toolbar for keyboard
    UIToolbar* keyboardToolbar;
    
    keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 460, 320, 44)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    keyboardToolbar.opaque = NO;
    [keyboardToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexibleSpace];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [doneButton setTintColor:kATGreenTint];
    [barItems addObject:doneButton];
    
    [keyboardToolbar setItems:barItems animated:YES];
    self.textView.inputAccessoryView = keyboardToolbar;
     */
    
    self.textView.layer.cornerRadius = 10;
    
}

- (void) dealloc {
    
    [self setDelegate:nil];
    [self setDataSource:nil];
    //[self setLabel:nil];
    [self setSegmentedToggle:nil];
    [self setSegmentedControl:nil];
    [self setTextField:nil];
    [self setTextView:nil];
    [self setButton:nil];
    [self setTitleLabel:nil];
    [self setDetailLabel:nil];
    //[self setTextLabel:nil];
    [self setActivityIndicator:nil];
    [self setCellType:nil];
    
}

- (void)layoutSubviews {
    
    /* 
        SDWebImage fixed width cell images
        Source: http://www.wrichards.com/blog/2011/11/sdwebimage-fixed-width-cell-images/
    */
    
    [super layoutSubviews];
    
    if (self.imageView) {

        // set a fix size for the image
        CGRect imageFrame = self.imageView.frame;
        imageFrame.size = CGSizeMake(63, 42);
        self.imageView.frame = imageFrame;
        
        // scale the image to fill
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        
        float limgW =  self.imageView.image.size.width;
        
        // position the text 8 points on the right of the image
        if(limgW > 0) {
            CGRect textFrame = self.textLabel.frame;
            textFrame.origin.x = imageFrame.origin.x + imageFrame.size.width + 8;
            self.textLabel.frame = textFrame;
            
            textFrame = self.detailTextLabel.frame;
            textFrame.origin.x = imageFrame.origin.x + imageFrame.size.width + 8;
            self.detailTextLabel.frame = textFrame;
            
        }
    }
    
    else if (self.pickerView) {
        CGRect frame = self.pickerView.frame;
        frame.size.height = 192;
        self.pickerView.frame = frame;
    }
    
    else if (self.datePickerView) {
        
        CGRect frame = self.datePickerView.frame;
        frame.size.height = 192;
        self.datePickerView.frame = frame;
        
    }
    
    
    
}

#pragma mark - Button delegates
- (void) doneButtonPressed:(id)sender {
    
    [self.textView resignFirstResponder];
    [self.delegate customCell:self textViewEditingDidEnd:self.textView];

}

- (IBAction)buttonTouchUpInside:(id)sender {

    if ([self.delegate respondsToSelector:@selector(customCell:buttonTouchUpInside:)]) {
         [self.delegate customCell:self buttonTouchUpInside:(UIButton *)sender];
     }

}

#pragma mark - Public methods
- (void) setEnabled:(BOOL)enabled {
    
    self.userInteractionEnabled = enabled;
    self.titleLabel.alpha = enabled ? 1 : 0.2f;
    self.detailLabel.alpha = enabled ? 1 : 0.2f;
    self.imageView.alpha = enabled ? 1 : 0.2f;
    
}

/*- (void) setCheckmark:(BOOL)enabled {
    
    NSString* imageName = enabled ? @"checkmark_green" : @"checkmark_gray";
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];

}*/

- (void) setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    
    self.segmentedControl.enabled = userInteractionEnabled;
    self.textView.textColor = userInteractionEnabled ? [UIColor blackColor] : [UIColor lightGrayColor];
    self.textField.textColor = userInteractionEnabled ? kATDarkGreenTint : [UIColor lightGrayColor];
    
}
/*
- (void) setButtonColor {
    
    for (int i = 0; i < self.segmentedControl.numberOfSegments; i++) {
         
        // setting title will reset image and setting image will reset title
        if (i == self.segmentedControl.selectedSegmentIndex) {
            // use image for selected button
            NSString* title = [[self.segmentedControl titleForSegmentAtIndex:i] lowercaseString];
            NSString* imageName =  [NSString stringWithFormat:@"button_down_%@", title];
            [self.segmentedControl setImage:[UIImage imageNamed:imageName] forSegmentAtIndex:i];
     
        } else {
            
            [self.segmentedControl setTitle:[self.dataSource customCell:self titleAtButtonIndex:i]  forSegmentAtIndex:i];
        }
    }
    
}*/

- (void) configure:(id)managedObject {
    
    // handle in subclass
    
}

#pragma mark - DatePicker delegates
- (IBAction)datePickerValueChanged:(UIDatePicker *)datePicker {
    
    if ([self.delegate respondsToSelector:@selector(customCell:datePickerValueChanged:)]) {
        [self.delegate customCell:self datePickerValueChanged:datePicker];
    }
    
}



#pragma mark - TextView delegates
-(void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([self.delegate respondsToSelector:@selector(customCell:textViewEditingDidBegin:)]) {
        [self.delegate customCell:self textViewEditingDidBegin:textView];
    }
    
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([self.delegate respondsToSelector:@selector(customCell:textViewEditingDidEnd:)]) {
        [self.delegate customCell:self textViewEditingDidEnd:textView];
    }
    
}

#pragma mark - TextField delegates
- (IBAction)textFieldDidEndOnExit:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(customCell:textFieldDidEndOnExit:)]) {
        [self.delegate customCell:self textFieldDidEndOnExit:(UITextField *)sender];
    } else {
        // Dismiss keyboard
        [sender resignFirstResponder];
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSCharacterSet *nonNumber=[[NSCharacterSet decimalDigitCharacterSet]invertedSet];
    
    return [string rangeOfCharacterFromSet:nonNumber].location !=NSNotFound?NO:YES;
}


- (IBAction)textFieldEditingDidBegin:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(customCell:textFieldEditingDidBegin:)]) {
        [self.delegate customCell:self textFieldEditingDidBegin:(UITextField *)sender];
    }
    
}

- (IBAction)textFieldEditingDidEnd:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(customCell:textFieldEditingDidEnd:)]) {
        [self.delegate customCell:self textFieldEditingDidEnd:(UITextField *)sender];
    }
    
}
- (IBAction)textFieldEditingChanged:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(customCell:textFieldEditingChanged:)]) {
        [self.delegate customCell:self textFieldEditingChanged:(UITextField *)sender];
    }
    
}

#pragma mark - Segmented control delegates
- (IBAction)segmentedControlValueChanged:(id)sender {
    
    if ([self.cellType isEqualToString:@"SegmentedToggle"]) {
        // Simulate the mechanism of a toggle button. "segmentedControl" is only a transparent dummy control that recognizes taps, while "cell.segmentedControl" is the real visible control.
        
        if (self.segmentedControl.selectedSegmentIndex == self.segmentedToggle.selectedSegmentIndex) {
            self.segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
            
        } else {
            self.segmentedControl.selectedSegmentIndex = self.segmentedToggle.selectedSegmentIndex;
        }
    }
    
    [self.delegate customCell:self segmentedControlValueChanged:self.segmentedControl];
    
}

-(IBAction)switchValueChanged:(id)sender{
    if ([self.delegate respondsToSelector:@selector(customCell:switchValueChanged:)]) {
        [self.delegate customCell:self switchValueChanged:(UISwitch *)sender];
    }
}

@end
