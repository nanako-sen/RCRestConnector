//
//  RCDataManager.h
//  RestConnector
//
//  Created by Anna Walser on 22/01/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCURLConnection.h"

@class RCActivityIndicator;

#define CONNECTION_FAIL_TAG 1000
#define RESPONSE_ERROR_401 401

// !!!: Classes which inherit from this baseclass
// should implement this methods:
//- (id)initWithDelegate:(id<DataManagerDelegate>)theDelegate 
//- (id)createDataStructure:(NSData*)data;


// Classes which implement a subclass of this class
// need to conform to this protocoll
@protocol DataManagerDelegate;

@interface RCDataManager : NSObject <RCURLConnectionDelegate>{
     id <DataManagerDelegate> delegate;
    NSString *connectionFailedMsg;
    BOOL debugState;
    RCActivityIndicator *activityIndicator;
}

@property (nonatomic, weak) id<DataManagerDelegate> delegate;
@property (nonatomic, strong) RCActivityIndicator *activityIndicator;
@property (nonatomic, strong) NSString *connectionFailedMsg;
@property (nonatomic, assign) BOOL debugMode;

//You can ether init with delegate imediatly or  without to set the delegate later
- (id)init;
- (id)initWithDelegate:(id<DataManagerDelegate>)theDelegate;


- (void)GETDataFromURL:(NSURL*)apiMethod forClass:(NSString*)className atKey:(NSString*)key withMappingDictionary:(NSDictionary*)mappingDictionary;
- (void)POSTData:(NSURL*)apiMethod withData:(NSData*)data;

- (NSURL*)createApiUrlForMethod:(NSString*)type;
- (NSURL*)createApiUrlForMethodWithoutApiKey:(NSString*)type;
- (NSDictionary*)getJSONObjectsFromData:(NSData*)data;
- (NSString*)apiBaseString;
//- (NSString*)apiToken;
- (void)responseErrorHandling:(int)code;
- (void)enableActivityIndicator:(BOOL)b;

@end


//Classes which use a DataManager class which inherits form this class
//must conform to this protocoll
@protocol DataManagerDelegate<NSObject>

@required
- (void)dataObjectCreated:(id)object;
@optional
- (void)connectionDidFailWithError:(NSError*)error;
- (void)responseError401;

@end


