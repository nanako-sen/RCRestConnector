//
//  RCURLConnection.h
//  RestConnector
//
//  Created by Anna Walser on 21/01/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef CONNECTION_UNAUTHORISED
#define CONNECTION_UNAUTHORISED 401
#endif

@protocol RCURLConnectionDelegate;

@interface RCURLConnection : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>{
	__weak id <RCURLConnectionDelegate> delegate;
	NSMutableData *receivedData;
	NSDate *lastModified;
	NSURLConnection *connection;
    NSError *connectionError;
    NSError *responseError;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSDate *lastModified;
@property (nonatomic, strong, readonly) NSError *connectionError;
@property (nonatomic, strong) NSError *responseError;

- (id) initWithURL:(NSURL *)theURL delegate:(id<RCURLConnectionDelegate>)theDelegate;
- (id) initWithURLForPost:(NSURL *)theURL withData:(NSData*)data delegate:(id<RCURLConnectionDelegate>)theDelegate;
@end


@protocol RCURLConnectionDelegate<NSObject>

- (void) connectionDidFail:(RCURLConnection *)connection;
- (void) connectionDidFinish:(RCURLConnection *)connection;

@end
