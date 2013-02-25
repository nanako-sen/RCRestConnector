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

@protocol URLConnectionDelegate;

@interface RCURLConnection : NSObject {
	__weak id <URLConnectionDelegate> delegate;
	NSMutableData *receivedData;
	NSDate *lastModified;
	NSURLConnection *connection;
    NSError *connectionError;
    NSError *responseError;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSDate *lastModified;
@property (nonatomic, retain, readonly) NSError *connectionError;
@property (nonatomic, retain) NSError *responseError;

- (id) initWithURL:(NSURL *)theURL delegate:(id<URLConnectionDelegate>)theDelegate;
- (id) initWithURLForPost:(NSURL *)theURL withData:(NSData*)data delegate:(id<URLConnectionDelegate>)theDelegate;
@end


@protocol URLConnectionDelegate<NSObject>

- (void) connectionDidFail:(RCURLConnection *)connection;
- (void) connectionDidFinish:(RCURLConnection *)connection;

@end
