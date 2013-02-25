//
//  RCURLConnection.m
//  RestConnector
//
//  Created by Anna Walser on 21/01/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCURLConnection.h"

@implementation RCURLConnection


@synthesize delegate;
@synthesize receivedData;
@synthesize lastModified;
@synthesize connection;
@synthesize connectionError;
@synthesize responseError;

//TODO: rework url connection http://developer.apple.com/library/ios/#samplecode/URLCache/Listings/Classes_URLCacheController_m.html#//apple_ref/doc/uid/DTS40008061-Classes_URLCacheController_m-DontLinkElementID_10
// implement url caching

/* This method initiates the load request. The connection is asynchronous,
 and we implement a set of delegate methods that act as callbacks during
 the load. */

- (id) initWithURL:(NSURL *)theURL delegate:(id<URLConnectionDelegate>)theDelegate
{
	if (self = [super init]) {
        
		self.delegate = theDelegate;
        
		/* Create the request. This application does not use a NSURLCache
		 disk or memory cache, so our cache policy is to satisfy the request
		 by loading the data from its source. */
        
		NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
													cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
												timeoutInterval:20];
        
		/* Create the connection with the request and start loading the
		 data. The connection object is owned both by the creator and the
		 loading system. */
        
		self.connection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
		if (self.connection == nil) {
			/* inform the user that the connection failed */
			NSString *message = NSLocalizedString (@"Unable to initiate request.",
												   @"NSURLConnection initialization method failed.");
            NSLog(@"%@", message);
			//URLCacheAlertWithMessage(message);
		}
	}
    
	return self;
}


- (id)initWithURLForPost:(NSURL *)theURL withData:(NSData*)data delegate:(id<URLConnectionDelegate>)theDelegate
{
    if (self = [super init]) {
        self.delegate = theDelegate;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL];
        request.HTTPMethod = @"POST";
        
        [request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request addValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:data];
        
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
		if (self.connection == nil) {
			/* inform the user that the connection failed */
			NSString *message = NSLocalizedString (@"Unable to initiate request.",
												   @"NSURLConnection initialization method failed.");
            NSLog(@"%@", message);
			//URLCacheAlertWithMessage(message);
		}

    }
    return self;
}


#pragma mark NSURLConnection delegate methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    
    if (code == CONNECTION_UNAUTHORISED) {
        //http://www.scribd.com/doc/80232926/160/Creating-an-NSError-Object
        self.responseError = [[NSError alloc] initWithDomain:NSStringFromClass([self.delegate class]) code:code userInfo:nil];
        self.receivedData = nil;
    } else {
        /* This method is called when the server has determined that it has
         enough information to create the NSURLResponse. It can be called
         multiple times, for example in the case of a redirect, so each time
         we reset the data capacity. */
        
        /* create the NSMutableData instance that will hold the received data */
        
        long long contentLength = [response expectedContentLength];
        if (contentLength == NSURLResponseUnknownLength) {
            contentLength = 500000;
        }
        self.receivedData = [NSMutableData dataWithCapacity:(NSUInteger)contentLength];
        
        /* Try to retrieve last modified date from HTTP header. If found, format
         date so it matches format of cached image file modification date. */
        
        if ([response isKindOfClass:[NSHTTPURLResponse self]]) {
            NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
            NSString *modified = [headers objectForKey:@"Last-Modified"];
            if (modified) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                /* avoid problem if the user's locale is incompatible with HTTP-style dates */
                [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
                
                [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
                self.lastModified = [dateFormatter dateFromString:modified];
            }
            else {
                /* default if last modified date doesn't exist (not an error) */
                self.lastModified = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            }
        }
    }
}


- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    /* Append the new data to the received data. */
    [self.receivedData appendData:data];
}


- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	connectionError = error;
    [self.delegate connectionDidFail:self];
}


- (NSCachedURLResponse *) connection:(NSURLConnection *)connection
				   willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	/* this application does not use a NSURLCache disk or memory cache */
    NSLog(@"URLConnection cache response");
    return nil;
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self.delegate connectionDidFinish:self];
}


@end

