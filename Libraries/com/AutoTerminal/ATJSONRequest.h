//
//  ATJSONRequest.h
//  AEMC
//
//  Created by i'Mac on 10/15/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "ATGlobal.h"
#import "Config.h"
#import <objc/runtime.h>

@interface NSObject (JSONCategory)
- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

@end

@implementation NSObject (JSONCategory)

- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];

        NSString *key = [NSString stringWithUTF8String:property_getName(property)];
        
        id value = [keyedValues objectForKey:key];
        if (value == nil) {
            continue;
        }
        
        //const char *property_name = property_getName(property);
        const char *type = property_getAttributes(property);

        //NSLog(@"%s %@", type, value);
        
        NSString * typeString = [NSString stringWithUTF8String:type];
        NSArray * attributes = [typeString componentsSeparatedByString:@","];
        NSString * typeAttribute = [attributes objectAtIndex:0];
        //NSString * propertyType = [typeAttribute substringFromIndex:1];
        NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];  //turns @"NSDate" into NSDate
        //Class typeClass = NSClassFromString(typeClassName);
        
        if (typeClassName) {
            if ([typeClassName isEqualToString:@"NSString"] && [value isKindOfClass:[NSNumber class]]) {
                value = [value stringValue];
            } else if ([typeClassName isEqualToString:@"NSNumber"] && [value isKindOfClass:[NSString class]]) {
                value = [NSNumber numberWithInteger:value];
            }
            
            [self setValue:value forKey:key];
            
        }
        
    }
    
    free(properties);
    
}

@end

@interface NSManagedObject (JSONCategory)
- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues;
@end

@implementation NSManagedObject (JSONCategory)

- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kATDateFormatUniversal];
    
    NSDictionary *attributes = [[self entity] attributesByName];
    for (NSString *attribute in attributes) {
        
        id value = [keyedValues objectForKey:attribute];
        if (value == nil) {
            continue;
        }
        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
        if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]])) {
            value = [value stringValue];
        
        } else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) && ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithInteger:[value integerValue]];
        
        } else if ((attributeType == NSFloatAttributeType) &&  ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithDouble:[value doubleValue]];
            
        } else if ((attributeType == NSDateAttributeType) && ([value isKindOfClass:[NSString class]]) && (dateFormatter != nil)) {
            
            if ([value hasPrefix:@"/Date"]) {
                value = ATDateFromJSONString(value);
            } else {
                value = [dateFormatter dateFromString:value];
            }
        }
        
        [self setValue:value forKey:attribute];
    }
}


@end


// MACRO
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

//#define kATURLMethodGetCountry @"GetCountry"
//#define kATURLMethodGetInspectionCompany @"GetInspectionCompany"

@class ATJSONRequest;

@protocol ATJSONRequestDelegate <NSObject>

@optional
- (void) jsonRequest:(ATJSONRequest*)jsonRequest didFinishWithData:(id) dataArray successful:(BOOL)successful;
//- (void) didFinishJSONRequest:(NSArray*) dataArray successful:(BOOL)successful methodName:(NSString*) methodName;
@end

@interface ATJSONRequest : NSObject

@property (nonatomic, assign) id <ATJSONRequestDelegate> delegate;
@property (nonatomic, retain) NSString* method;
@property (nonatomic, retain) NSDictionary* input;

- (void) sendJSONRequestWithDictionary:(NSDictionary*) dictionary methodName:(NSString*) methodName;
- (void) sendJSONRequestWithDictionary:(NSDictionary*) dictionary methodName:(NSString*) methodName showSuccessfulMessage:(BOOL)showMessage;
- (void) sendJSONRequestWithDictionary:(NSDictionary*) dictionary methodName:(NSString*) methodName encode:(BOOL)encode showSuccessfulMessage:(BOOL)showMessage;
- (void) sendPHPRequestWithParameter:(NSString*) cmdParam methodName:(NSString*) methodName urlSelf:(NSString*)urlAssign;
@end


