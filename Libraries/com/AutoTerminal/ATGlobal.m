//
//  ATGlobal.m
//  AEMC
//
//  Created by i'Mac on 11/23/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "ATGlobal.h"
#import "Config.h"

@implementation ATGlobal

#pragma mark - Date functions

NSString* ATFormatDateMedium(NSDate* date)
{
    // Convert to "MMM dd, yyyy"
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    return [dateFormatter stringFromDate:date];
    //dateFormatter.timeZone = [NSTimeZone systemTimeZone];
}

NSString* ATFormatDateMediumFromString(NSString* date)
{
    // Convert from "yyyy-MM-dd'T'HH:mm:ssZ" to medium date format
    if ([date isEqualToString:@""]) {
        return @"";
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = kATDateFormatUniversal;
    
    return ATFormatDateMedium([dateFormatter dateFromString:date]);
}

NSString* ATFormatDateTimeShort(NSDate* date)
{
    // Convert to "MM/DD/YY hh:mm"
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    return [dateFormatter stringFromDate:date];
}

NSString* ATFormatDateTimeUniversal(NSDate* date)
{
    // Convert to "yyyy-MM-dd'T'HH:mm:ssZ" 
    NSDateFormatter* universalDateFormatter = [[NSDateFormatter alloc] init];
    universalDateFormatter.dateFormat = kATDateFormatUniversal;
    return date ? [universalDateFormatter stringFromDate:date] : @"";
    
}

NSString* ATFormatTime (NSDate* date)
{
    // Convert to "HH:mm AM"
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.timeStyle = NSDateFormatterShortStyle;
    return date ? [timeFormatter stringFromDate:date] : @"";
    
}

NSString* ATFormatDateShort(NSDate* date)
{
    // Convert to yyyy'-'MM'-'dd
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd"];
    
    return [dateFormatter stringFromDate:date];
}

NSString* ATFormatMonthDate(NSDate* date)
{
    // Convert to "MMM d"
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d"];
    
    return [dateFormatter stringFromDate:date];
}

NSString* ATFormatDate(NSDate* date)
{
    // Convert to "d"
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    
    return [dateFormatter stringFromDate:date];
}

NSString* ATFormatMonth(NSDate* date)
{
    // Convert to "MMM"
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM"];
    
    return [dateFormatter stringFromDate:date];
}

NSString* ATFormatDayName(NSDate* date)
{
    // Convert to "EEEE"
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    
    return [dateFormatter stringFromDate:date];
}

NSArray* ATCreateSortDescriptorsWithKeys(NSArray* sortKeys, NSArray* sortOrders)
{
    
    // construct sort descriptors
    NSMutableArray* sortDescriptors = [[NSMutableArray alloc] init];
    
    [sortKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        // if no order is defined, use "ascending"
        BOOL ascending = (sortOrders) ? [[sortOrders objectAtIndex:idx] boolValue] : YES;
        
        // create sort descriptor
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:obj ascending:ascending];
        
        // add to array
        [sortDescriptors addObject:sortDescriptor];
        
    }];
    
    return sortDescriptors;
}

NSInteger ATCompareDates(NSDate *dateA, NSDate *dateB)
{
    
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    /*NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
     fromDate:dateA
     toDate:dateB
     options:0];*/
    
    return [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:dateB] -
    [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:dateA];
    
    //return components.day;
}

//convert to NSDate from "\Date(xxxxxxxxxxxx)\"
NSDate* ATDateFromJSONString(NSString* date)
{
    
    NSCharacterSet *charactersToRemove = [[ NSCharacterSet decimalDigitCharacterSet ] invertedSet ];
    NSString* milliseconds = [date stringByTrimmingCharactersInSet:charactersToRemove];
    
    if (milliseconds != nil) {
        NSTimeInterval  seconds = [milliseconds doubleValue] / 1000;
        return [NSDate dateWithTimeIntervalSince1970:seconds];
    }
    return nil;

}

void ATResizeFontForLabel(UILabel* aLabel, int maxSize, int minSize) {
    // use font from provided label so we don't lose color, style, etc
    UIFont *font = aLabel.font;
    
    // start with maxSize and keep reducing until it doesn't clip
    for(int i = maxSize; i >= minSize; i--) {
        font = [font fontWithSize:i];
        CGSize constraintSize = CGSizeMake(aLabel.frame.size.width, MAXFLOAT);
        
        // This step checks how tall the label would be with the desired font.
        CGRect labelSize = [aLabel.text boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
        
        if (labelSize.size.height <= aLabel.frame.size.height)
            break;
    }
    // Set the UILabel's font to the newly adjusted font.
    aLabel.font = font;
}

NSNumber* ATRound(CGFloat value, NSInteger digit) {
    
    CGFloat rounded = value;
    
    if (digit > 0) {
        rounded = roundf(value/pow(10.0, digit)) * pow(10.0, digit);
    }
    
    return @(rounded);
    
}


#pragma mark - Image function

UIImage* ATFilledImageFrom(UIImage * source, UIColor * color) {
    
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}


/* Resize an image
 Return a scaled down copy of the image.
 */

UIImage* ATResizeImage(UIImage *image, CGSize newSize)
{
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

@end
