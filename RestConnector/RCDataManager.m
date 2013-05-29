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
#import "RCConnectionConfig.h"


@interface RCDataManager(){
    NSString *_apiToken;
    //Authentication *_auth;
    UIApplication *_application;
    BOOL _enableActivityIndicator;
    NSString *_objectClassName;
    NSString *_jsonRootKey;
    NSDictionary *_mappingDictionary;
}
- (NSArray*)createDataStructure:(NSData*)data;
- (void)connectionDidFail:(RCURLConnection *)connection;
- (void)connectionDidFinish:(RCURLConnection *)connection;
- (void)responseError401;
- (void)responseErrorHandling:(int)code;
- (void)stopActivityIndicator;
- (void)startActivityIndicator;

@end

@implementation RCDataManager

@synthesize delegate = _delegate, connectionFailedMsg = _connectionFailedMsg, debugMode = _debugMode, activityIndicator = _activityIndicator;

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
    }
    return self;
}

//http://stackoverflow.com/questions/5197446/nsmutablearray-force-the-array-to-hold-specific-object-type-only

- (NSArray*)createDataStructure:(NSData*)data
{    
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    NSDictionary *resultDict = [self getJSONObjectsFromData:data];
    
    if (resultDict && finalArray) {
        NSDictionary *jsonDict = [resultDict objectForKey:_jsonRootKey];
        for (NSDictionary *dict in jsonDict)
        {
            id object = [[NSClassFromString(_objectClassName) alloc] init];
            for(NSString *mappedKey in [_mappingDictionary allKeys])
            {
                id restValue = [dict valueForKey:mappedKey];
 
                NSString *realKey = _mappingDictionary[mappedKey];
                [object setValue:restValue forKey:realKey]; 
            }
            [finalArray addObject:object];
        }
    }
    NSArray * arr = [finalArray copy]; //returning NSarray instead of mutable - copy makes an immutable copy
    return arr;
}

- (void)enableActivityIndicator:(BOOL)b
{
    _enableActivityIndicator = b;
}

//TODO:mothod for not using mapping dictionary for kvc
- (void)GETDataFromURL:(NSURL*)apiMethod
              forClass:(NSString*)className
                 atKey:(NSString*)key
 withMappingDictionary:(NSDictionary*)mappingDictionary
{
    _objectClassName = className;
    _jsonRootKey = key;
    _mappingDictionary = mappingDictionary;
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

//- (id)createDataStructure:(NSData*)data { return nil;}


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


- (NSDictionary*)getJSONObjectsFromData:(NSData*)data
{
    
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
