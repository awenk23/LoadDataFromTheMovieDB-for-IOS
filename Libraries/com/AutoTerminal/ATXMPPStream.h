//
//  ATXMPPStream.h
//  ATNZ
//
//  Created by i'Mac on 5/1/13.
//  Copyright (c) 2013 AutoTerminal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"

@protocol ATXMPPStreamDelegate
- (void)newMessageReceived:(NSDictionary *)messageContent;
- (void)didGoOnline;
- (void)didDisconnect:(NSError *)error;
@end

@interface ATXMPPStream : NSObject

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, assign) id<ATXMPPStreamDelegate> delegate;
@property (nonatomic, readonly) BOOL connected;

- (BOOL)connectAnonymously:(NSString*) server serverName:(NSString*)serverName;
- (void)goOffline;
- (void)goOnline;
- (void)disconnectAfterSending:(BOOL)afterSending;
- (void)sendMessage:(NSString*) message to:(NSString*)to;
- (void)sendMessage:(NSString*) message to:(NSString*)to extension:(NSDictionary*) extension;

@end
