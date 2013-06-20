//
//  RCDataManager.m
//  RestConnector
//
//  Created by Anna Walser on 22/01/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCRestConnector.h"
#import "RCURLConnection.h"
#import "RCActivityIndicator.h"
#import "RCDataCache.h"
#import "RCObjectMapper.h"

@interface RCRestConnector(){
    NSString *_apiToken;
    //Authentication *_auth;
    UIApplication *_application;
    BOOL _enableActivityIndicator;

    NSString *_jsonRootKey;
    NSDictionary *_mappingDictionary;

}
- (NSArray*)createDataStructure:(NSData*)data;
/**
 Returns the value of a key in a Json object
 @param mappedValue can be a string or an other dictionary
 @param dict the dictionary to search
 */
- (void)connectionDidFail:(RCURLConnection *)connection;
- (void)connectionDidFinish:(RCURLConnection *)connection;
- (void)responseError401;
- (void)responseErrorHandling:(int)code;
- (void)stopActivityIndicator;
- (void)startActivityIndicator;

@end

@implementation RCRestConnector

@synthesize delegate = _delegate, connectionFailedMsg = _connectionFailedMsg, debugMode = _debugMode, activityIndicator = _activityIndicator, cachingEnabled = _cachingEnabled, cacheRefreshInterval = _cacheRefreshInterval, objectClassName = _objectClassName;

- (id)init
{
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<DataManagerDelegate>)theDelegate
{
    self = [super init];
    if (self) {
        self.activityIndicator = [RCActivityIndicator sharedInstance];
        //_auth = [Authentication sharedInstance];
        _application = [UIApplication sharedApplication];
        _enableActivityIndicator = YES;
        self.delegate = theDelegate;
        _cachingEnabled = YES;
    }
    return self;
}


//TODO:mothod for not using mapping dictionary for kvc

/**
 Sends the request to the service and sets the properties for processing when the response comes back.
 @param apiMethod Rest url
 @param className the object class which needs to be created
 @param key the start root key of the Json object
 @param mappingDictionary defines how object properties and json properties need to get mapped. 
        Values in the dictionary can be nested dictionaries to get properties deeper in the json object
        eg: @{@"likes": @{@"likes":@{@"data":@"name"}}, @"postId":@"id", @"name":@{@"from": @"name"}}
 */
- (void)GETDataFromURL:(NSURL*)apiMethod forClass:(NSString*)className atKey:(NSString*)key
 withMappingDictionary:(NSDictionary*)mappingDictionary
{
    NSArray* data;
    self.objectClassName = className;
    _jsonRootKey = key;
    _mappingDictionary = mappingDictionary;
    
    //TODO: only do this when chaching is wanted
    if (_cachingEnabled)
    {
        RCDataCache *dataCache = [[RCDataCache alloc]initWithClass:className];
        if(self.cacheRefreshInterval != 0) dataCache.cacheRefreshInterval = self.cacheRefreshInterval;
        [dataCache prepareCache];

        //check if db contains data or data up to date
        if (![dataCache dataNeedsRefresh]) {
            [self startActivityIndicator];
            [self GETDataFromURL:apiMethod];
        } else {
            data = [dataCache getCachedData] ;
            [self.delegate dataObjectCreated:data];
        }
    }else {
        [self startActivityIndicator];
        [self GETDataFromURL:apiMethod];
    }
    //if old or no data
    
}

- (void)GETDataFromURL:(NSURL*)apiMethod
{
    NSLog(@"calling: %@", apiMethod);
    
    (void)[[RCURLConnection alloc] initWithURL:apiMethod delegate:(id)self];
}

- (void)POSTData:(NSURL*)apiMethod withData:(NSData*)data
{
     (void)[[RCURLConnection alloc] initWithURLForPost:apiMethod withData:data delegate:(id)self];
}


//http://stackoverflow.com/questions/5197446/nsmutablearray-force-the-array-to-hold-specific-object-type-only
//TODO: nested json values NSArray *responseArray = [[[responseString JSONValue] objectForKey:@"d"] objectForKey:@"results"]; - done

//returns set of objects
- (NSArray*)createDataStructure:(NSData*)data
{
    NSArray *set = nil;
    RCObjectMapper *objMapper = [RCObjectMapper sharedInstance];
    if (_cachingEnabled)
    {//save data in database
        set = [objMapper insertAndGetObjectsFromJSON:data onJsonRootKey:_jsonRootKey forClass:_objectClassName withMappingDictionary:_mappingDictionary];
    }else {
        set =  [objMapper createObjectsFromJSON:data onJsonRootKey:_jsonRootKey forClass:_objectClassName withMappingDictionary:_mappingDictionary ];
    }
    return set;
}


#pragma mark - URLConnector delegates

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
            self.connectionFailedMsg = (conError.code == NSURLErrorCannotConnectToHost) ? @"You are not connected to the Internet. Please check your connection settings." : [NSString stringWithFormat:@"A connection error occurred. Error Code: %ld", (long)conError.code];
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

#pragma mark - ActivityIndicator methods

- (void)enableActivityIndicator:(BOOL)b
{
    _enableActivityIndicator = b;
}

- (void)startActivityIndicator
{
    if (_enableActivityIndicator) {
        //we need to bring the indicator to the front before we start it
        [self.activityIndicator startActivityView];
        
        _application.networkActivityIndicatorVisible = YES;
    }
}

- (void)stopActivityIndicator
{
    [self.activityIndicator stopActivityView];
    _application.networkActivityIndicatorVisible = NO;
}


#pragma mark - dynamic data binding


#pragma mark - common methods

//- (NSString*)apiBaseString
//{
//    return [NSString stringWithFormat:@"%@/%@",[self apiPath], [self apiToken]];
//}
//
//- (NSString*)apiBaseStringWithoutApiKey
//{
//    return [NSString stringWithFormat:@"%@",[self apiPath]];
//}


//- (NSURL*)createApiUrlForMethod:(NSString*)type
//{
//    
//    NSString *requestURL = [NSString stringWithFormat:@"%@/%@",[self apiBaseString],type];
//    NSURL *url = [NSURL URLWithString:requestURL];
//    
//    NSLog(@"requested: %@",url);
//    return url;
//}
//
//- (NSURL*)createApiUrlForMethodWithoutApiKey:(NSString*)type
//{
//    NSString *requestURL = [NSString stringWithFormat:@"%@/%@",[self apiBaseStringWithoutApiKey],type];
//    NSURL *url = [NSURL URLWithString:requestURL];
//    
//    NSLog(@"requested: %@",url);
//    return url;
//}




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
