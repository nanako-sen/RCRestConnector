//
//  RCDataManager.m
//  RestConnector
//
//  Created by Anna Walser on 22/01/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCDataManager.h"
#import "RCURLConnection.h"
#import "RCActivityIndicator.h"


@interface RCDataManager(){
    NSString *_apiToken;
    //Authentication *_auth;
    UIApplication *_application;
}

@end

@implementation RCDataManager

@synthesize delegate = _delegate, connectionFailedMsg = _connectionFailedMsg, debugMode = _debugMode, activityIndicator = _activityIndicator;

- (id)init
{
    self = [super init];
    if (self) {
        self.activityIndicator = [RCActivityIndicator sharedInstance];
        //_auth = [Authentication sharedInstance];
        _application = [UIApplication sharedApplication];
    }
    return self;
}

- (void)GETData:(NSURL*)apiMethod
{
    [self startActivityIndicator];

    (void)[[RCURLConnection alloc] initWithURL:apiMethod delegate:(id)self];
}


- (void)POSTData:(NSURL*)apiMethod withData:(NSData*)data
{
     (void)[[RCURLConnection alloc] initWithURLForPost:apiMethod withData:data delegate:(id)self];
}

- (void) connectionDidFinish:(RCURLConnection *)connection
{
    [self stopActivityIndicator];
    
    id data = [self createDataStructure:(NSData*)connection.receivedData];
    [self.delegate dataObjectCreated:data];
}

- (void) connectionDidFail:(RCURLConnection *)connection
{
    NSLog(@"connection faild, error: %@", connection.connectionError);
    
    [self stopActivityIndicator];
    
    NSError *conError = connection.connectionError;
    //url error code reference https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/Reference/reference.html
    if (![self.delegate respondsToSelector:@selector(connectionDidFailWithError:)])
    {
        if(self.debugMode){
            self.connectionFailedMsg = [conError.userInfo objectForKey:@"NSLocalizedDescription"];
        }else {
            self.connectionFailedMsg = (conError.code == NSURLErrorCannotConnectToHost) ? @"You are not connected to the Internet. Please check your connection settings." : [NSString stringWithFormat:@"An connection error occoured. Error Code: %ld", (long)conError.code];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                                        message:self.connectionFailedMsg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        alert.tag = CONNECTION_FAIL_TAG;
        
        [alert show];
    } else
        [self.delegate connectionDidFailWithError:connection.connectionError];
}

- (void)startActivityIndicator
{
    //we need to bring the indicator to the front before we start it
    [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startActivityView];
    
    _application.networkActivityIndicatorVisible = YES;
}

- (void)stopActivityIndicator
{
    [self.activityIndicator stopActivityView];
    _application.networkActivityIndicatorVisible = NO;
}

#pragma mark - dynamic data binding

- (id)createDataStructure:(NSData*)data { return nil;}


#pragma mark - common methods

- (NSString*)apiBaseString
{
//    return [NSString stringWithFormat:@"%@/%@",[self apiPath], [self apiToken]];
    return [NSString stringWithFormat:@"%@",[self apiPath]];
}

- (NSString*)apiBaseStringWithoutApiKey
{
    return [NSString stringWithFormat:@"%@",[self apiPath]];
}

- (NSString*)apiPath
{
    return @"http://192.168.3.158/1.0"; //local
}

//- (NSString*)apiToken
//{
//    return  [_auth getApiKey];
//}


- (NSURL*)createApiUrlForMethod:(NSString*)type
{
    
    NSString *requestURL = [NSString stringWithFormat:@"%@/%@",[self apiBaseString],type];
    NSURL *url = [NSURL URLWithString:requestURL];
    
    NSLog(@"requested: %@",url);
    return url;
}

- (NSURL*)createApiUrlForMethodWithoutApiKey:(NSString*)type
{
    NSString *requestURL = [NSString stringWithFormat:@"%@/%@",[self apiBaseStringWithoutApiKey],type];
    NSURL *url = [NSURL URLWithString:requestURL];
    
    NSLog(@"requested: %@",url);
    return url;
}


- (NSDictionary*)getJSONObjectsFromData:(NSData*)data{
    
    NSError*    error       = nil;
    NSDictionary*    resultData = nil;
    resultData  = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:kNilOptions
                                                                     error:&error];
    
    if (error){
        NSLog(@"JSON Error: %@ %@", error, [error userInfo]);
        resultData = nil;
    }
    return resultData;

}

- (void)responseErrorHandling:(int)code
{
    switch (code) {
        case CONNECTION_UNAUTHORISED:
            if ([delegate respondsToSelector:@selector(responseError401)])
                [delegate responseError401];
            else
                [self responseError401];
 
            break;
        default:
            break;
    }
}

- (void)responseError401
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response Error"
                                                    message:@"Response Code: 401"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    alert.tag = RESPONSE_ERROR_401;
    
    [alert show];

}


@end
