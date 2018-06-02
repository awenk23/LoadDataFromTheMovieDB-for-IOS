//
//  ATJSONRequest.m
//  AEMC
//
//  Created by i'Mac on 10/15/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "ATJSONRequest.h"

// Private
@interface ATJSONRequest ()
{
    BOOL _showMessage;
}


@end

@implementation ATJSONRequest

@synthesize method = _method;
@synthesize input = _input;

- (id) init {
    self = [super init];
    _showMessage = YES; // default show successful messages
    return self;
}

- (void) sendJSONRequestWithDictionary:(NSDictionary*) dictionary methodName:(NSString*) methodName  {
 
    [self sendJSONRequestWithDictionary:dictionary methodName:methodName encode:YES];
    
}

- (void) sendJSONRequestWithDictionary:(NSDictionary*) dictionary methodName:(NSString*) methodName encode:(BOOL)encode showSuccessfulMessage:(BOOL)showMessage {
    
    _showMessage = showMessage;
    [self sendJSONRequestWithDictionary:dictionary methodName:methodName encode:encode];

}

- (void) sendJSONRequestWithDictionary:(NSDictionary*) dictionary methodName:(NSString*) methodName showSuccessfulMessage:(BOOL)showMessage {
    
    _showMessage = showMessage;
    [self sendJSONRequestWithDictionary:dictionary methodName:methodName];

}

- (void) sendJSONRequestWithDictionary:(NSDictionary*) dictionary methodName:(NSString*) methodName encode:(BOOL)encode {
    
    NSError* error;
    
    _method = methodName;
    _input = dictionary;
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kATURLJSON, methodName, nil]];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONReadingMutableContainers error:&error];

    NSData* postData = jsonData;
    
    if (encode) {
        // construct query string
        NSString* jsonQuery = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // escape special characters like & amp
        jsonQuery = [jsonQuery stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        jsonQuery = [jsonQuery stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

        //NSLog(@"%@", jsonQuery);
        
        postData = [jsonQuery dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    // construct HTTP request
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init];
    [httpRequest setURL:url];
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpRequest setHTTPMethod:@"POST"];
    [httpRequest setHTTPBody:postData];
    [httpRequest setTimeoutInterval:30];
    // send request, get response
    
    dispatch_async(kBgQueue, ^{
        //NSData* data = [NSData dataWithContentsOfURL:kLoginURL];
        NSData* httpResponse = [NSURLConnection sendSynchronousRequest:httpRequest returningResponse:nil error:nil];
        [self performSelectorOnMainThread:@selector(fetchResponse:) withObject:httpResponse waitUntilDone:YES];
    });
    
}

- (void) sendPHPRequestWithParameter:(NSString*) cmdParam methodName:(NSString*) methodName urlSelf:(NSString*)urlAssign{
    
    _method = methodName;
    
    // escape special characters like & amp
    //urlAssign = [urlAssign stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    urlAssign = [urlAssign stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    urlAssign = [urlAssign stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    cmdParam = [cmdParam stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL* url = [NSURL URLWithString:urlAssign];
    //NSLog(@"%@",url);
    
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init];
    [httpRequest setURL:url];
    [httpRequest setHTTPMethod:@"GET"];
    [httpRequest setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //form-data block
    NSMutableData *postData = [NSMutableData data];
    //    NSString* param=[NSString stringWithFormat:@"%@=%@", @"cmd", cmdParam];
    //    NSLog(@"%@",param);
    [postData appendData:[cmdParam dataUsingEncoding:NSUTF8StringEncoding]];
    [httpRequest setHTTPBody:postData];
    [httpRequest setTimeoutInterval:900];
    
    // send request, get response
    dispatch_async(kBgQueue, ^{
        //NSData* data = [NSData dataWithContentsOfURL:kLoginURL];
        NSHTTPURLResponse *response = nil;
        NSData* httpResponse = [NSURLConnection sendSynchronousRequest:httpRequest returningResponse:&response error:nil];
        [self performSelectorOnMainThread:@selector(fetchResponse:) withObject:httpResponse waitUntilDone:YES];
    });
    
}


- (void) fetchResponse:(NSData*) responseData {
    
    NSString* message;
    NSString* title = @"Operation Failure";
    NSError* error;
    id resultSet;
    NSInteger status;
    
    BOOL successful = NO;

    // No response
    if (responseData != nil) {
        successful = YES;
    } else {
        message = @"Unable to connect to the server";
        _showMessage = YES; // always show message for unsuccessful calls
    }
    
    /* //-- for debug
    resultSet = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:resultSet options:NSJSONWritingPrettyPrinted error:&error];
    
    NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    *///-- end debug
    
    
    if (successful) {
        // Convert JSON response data into dictionary
        NSDictionary* headerData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    
        //successful = [[headerData objectForKey:@"Status"] integerValue] == 1 || [[headerData objectForKey:@"Status"] integerValue] == 2;
    
        //successful = [[headerData objectForKey:@"Status"] integerValue] == 1;
        status = [[headerData objectForKey:@"total_results"] integerValue]>0;
        successful = status == 1 || status == 2;
        
        if (successful) {
            title = @"Server Message";
            
            //-- for debug
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:headerData options:NSJSONWritingPrettyPrinted error:&error];
            
            //NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
            //-- end debug
            
            resultSet = headerData;
            /*
            // Convert JSON data string into NSData
            // Check for NULL tag
            //BOOL nullData = [[headerData objectForKey:@"Tag"] isKindOfClass:[NSNull class]];
            NSNumber* total = [headerData objectForKey:@"total_results"];
            NSNumber* total_pages = [headerData objectForKey:@"total_pages"];
            if (total) {
                resultSet = [NSDictionary dictionaryWithObjectsAndKeys:total, @"Total",total_pages, @"totalPages", [headerData objectForKey:@"results"], @"Results", nil];
            }
//            else if(status==2){
//                resultSet =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:status],@"status",[headerData objectForKey:@"Tag"],@"Results", nil];
//            }
            else {
                resultSet = [headerData objectForKey:@"Tag"];
            }
            */
            BOOL arrayData = [resultSet isKindOfClass:[NSArray class]];
            
            if (arrayData) {
                
                /*
                NSData* tagData = [[headerData objectForKey:@"Tag"] dataUsingEncoding:NSUTF8StringEncoding];
                
                // Convert JSON NSData into NSDictionary
                resultSet = [NSJSONSerialization JSONObjectWithData:tagData options:0 error:&error];*/
            } else {
                message = [headerData objectForKey:@"Message"];
            }
            
        } else {
            // always show message for unsuccessful calls
            if (status == 0) _showMessage = YES; 
            message = [headerData objectForKey:@"Message"];
        }
        
    }
    
    if (message && _showMessage) {
/*        if (![message isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        }
 */
        if (![message isEqualToString:@""]&&![message isEqualToString:@"Invalid vehicle id"]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }

    }
    
    // call protocol
    [self.delegate jsonRequest:self didFinishWithData:resultSet successful:successful];

}

- (void) dealloc {
    
    self.delegate = nil;

}

@end
