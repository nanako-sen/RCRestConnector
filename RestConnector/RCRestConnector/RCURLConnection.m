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


- (id) initWithURL:(NSURL *)theURL delegate:(id<RCURLConnectionDelegate>)theDelegate
{
	if (self = [super init]) {
        
		self.delegate = theDelegate;

		NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
													cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
												timeoutInterval:20];
        
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


- (id)initWithURLForPost:(NSURL *)theURL withData:(NSData*)data delegate:(id<RCURLConnectionDelegate>)theDelegate
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
       long long contentLength = [response expectedContentLength];
        if (contentLength == NSURLResponseUnknownLength) {
            contentLength = 500000;
        }
        self.receivedData = [NSMutableData dataWithCapacity:(NSUInteger)contentLength];
        
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
    return nil;
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self.delegate connectionDidFinish:self];
}


@end

