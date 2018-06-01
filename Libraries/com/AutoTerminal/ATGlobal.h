//
//  ATGlobal.h
//  AEMC
//
//  Created by i'Mac on 11/23/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

// Global values
#define kATBooleanYES @"true"
#define kATBooleanNO @"false"

#define kATFavoriteSign @"★"

// Date format
#define kATDateFormatUniversal @"yyyy-MM-dd"

// Colors
#define kATGreenTint [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]
#define kATDarkGreenTint [UIColor colorWithRed:0/255 green:111.0/255 blue:76.0/255 alpha:.85f]
#define kATLightGrayTint [UIColor colorWithRed:212.0/255.0 green:212.0/255.0 blue:212.0/255.0 alpha:1.0f]

// Macros
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height < 568) ? NO : YES)
#define IS_IPHONE6 (([[UIScreen mainScreen] bounds].size.height < 667) ? NO : YES)
#define IS_IPHONE6P ([[UIScreen mainScreen] scale] > 2.1f)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IOS7 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
#define IS_IOS8 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)

#define IPAD_TABBAR_H ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) ? 49 : 56)
#define PICKER_H 180

#import <Foundation/Foundation.h>

@interface ATGlobal : NSObject

// Date functions
NSString* ATFormatDateMedium(NSDate* date);
NSString* ATFormatDateMediumFromString(NSString* date);
NSString* ATFormatDateTimeShort(NSDate* date);
NSString* ATFormatDateTimeUniversal(NSDate* date);
NSString* ATFormatTime (NSDate* date);
NSDate* ATDateMake(NSString* string);
NSInteger ATCompareDates(NSDate *dateA, NSDate *dateB);

NSString* ATFormatMonthDate(NSDate* date);
NSString* ATFormatDateShort(NSDate* date);
NSString* ATFormatMonth(NSDate* date);
NSString* ATFormatDate(NSDate* date);
NSString* ATFormatDayName(NSDate* date);

NSDate* ATDateFromJSONString(NSString* date);

// Others
NSArray* ATCreateSortDescriptorsWithKeys(NSArray* sortKeys, NSArray* sortOrders);
void ATResizeFontForLabel(UILabel* aLabel, int maxSize, int minSize);
NSNumber* ATRound(CGFloat value, NSInteger digit);

// Image
UIImage* ATFilledImageFrom(UIImage* source, UIColor* color);
UIImage* ATResizeImage(UIImage *image, CGSize newSize);

@end
