//
//  ATXMPPStream.m
//  ATNZ
//
//  Created by i'Mac on 5/1/13.
//  Copyright (c) 2013 AutoTerminal. All rights reserved.
//

#import "ATXMPPStream.h"
#import "ATGlobal.h"

@implementation ATXMPPStream

-(id) init {
    
    if ((self = [super init])) {
        [self setupStream];
    }
    
    return self;
}

-(void) dealloc {
    
    _delegate = nil;
    
}

- (void)setupStream {
    
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

}

- (void)goOnline {
    
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
    [_delegate didGoOnline];
    
}

- (void)goOffline {
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];

}

- (BOOL)connectAnonymously:(NSString*) server serverName:(NSString*)serverName {
    
    //NSString *jabberID = [NSString  stringWithFormat:@"@%@", server];

    if (![_xmppStream isDisconnected]) {
        [_delegate didGoOnline];
        return YES;
    }
    
    if (server == nil) {
        return NO;
    }
    
    [_xmppStream setHostName:server];
    [_xmppStream setHostPort:5222];
    [_xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"@%@", serverName]]];
    
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:60 error:&error]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return NO;
    }
    
    return YES;
    
}

- (void)disconnectAfterSending:(BOOL)afterSending {
    
    [self goOffline];
    if (afterSending) {
        [_xmppStream disconnectAfterSending];
    } else {
        [_xmppStream disconnect];
    }
    
}

- (BOOL) connected {

    return ![_xmppStream isDisconnected];

}

- (void)sendMessage:(NSString*) message to:(NSString*)to extension:(NSDictionary*) extensions {
    
    if([message length] > 0) {
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        NSXMLElement *xmlMessage = [NSXMLElement elementWithName:@"message"];
        
        [xmlMessage addAttributeWithName:@"type" stringValue:@"chat"];
        [xmlMessage addAttributeWithName:@"to" stringValue:to];
        [xmlMessage addChild:body];
        
        NSDictionary* userInfo = [extensions objectForKey:@"userInfo"];
        
        if (userInfo) {
            NSXMLElement *ibcChat = [NSXMLElement elementWithName:@"ibcchat" xmlns:@"http://support.ibcjapan.co.jp:8088/IBCChat/plugins/ibccontacts"];
            
            [userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSXMLElement *element = [NSXMLElement elementWithName:key];
                [element setStringValue:obj];
                [ibcChat addChild:element];
            }];
            
            [xmlMessage addChild:ibcChat];

        }
        
        NSDictionary* vehicleInfo = [extensions objectForKey:@"vehicleInfo"];
        
        if (vehicleInfo) {
            NSXMLElement *vehicleOffer = [NSXMLElement elementWithName:@"vehicle-offer" xmlns:@"http://support.ibcjapan.co.jp:8088/IBCChat/plugins/vehicleoffer"];
            
            [vehicleInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSXMLElement *element = [NSXMLElement elementWithName:key];
                [element setStringValue:obj];
                [vehicleOffer addChild:element];
            }];
            
            [xmlMessage addChild:vehicleOffer];

        }
        
        
        NSLog(@"%@", xmlMessage);
        
        [self.xmppStream sendElement:xmlMessage];
    }
    
}

- (void)sendMessage:(NSString*) message to:(NSString*)to {
    
    if([message length] > 0) {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        NSXMLElement *xmlMessage = [NSXMLElement elementWithName:@"message"];
        [xmlMessage addAttributeWithName:@"type" stringValue:@"chat"];
        [xmlMessage addAttributeWithName:@"to" stringValue:to];
        [xmlMessage addChild:body];
        
        //[self.xmppStream sendElement:xmlMessage];
    }
    
}

#pragma mark - XMPPStream delegates
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    
    [_delegate didDisconnect:error];
    
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    
    NSError *error = nil;
    //[[self xmppStream] authenticateAnonymously:&error];
    if (![_xmppStream authenticateAnonymously:&error]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {

    [self goOnline];
    
}

/*
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:myUsername]) {
        if ([presenceType isEqualToString:@"available"]) {
            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"openfire"]];
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"openfire"]];
        }
    }
    
}
*/

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
    
    NSString *msg = [[message elementForName:@"body"] stringValue];
    
    if (msg) {
        
        NSString *from = [[message attributeForName:@"from"] stringValue];
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:msg forKey:@"message"];
        [m setObject:from forKey:@"from"];
        [m setObject:[NSDate date] forKey:@"date"];
        [_delegate newMessageReceived:m];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error {

    

}

@end
