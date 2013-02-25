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

@protocol DataManagerDelegate;

@protocol DataManagerBaseSubclassDelegate;

@interface RCDataManager : NSObject <URLConnectionDelegate>{
     id <DataManagerDelegate> delegate;
    NSString *connectionFailedMsg;
    BOOL debugState;
    RCActivityIndicator *activityIndicator;
}

@property (nonatomic, assign) id<DataManagerDelegate> delegate;
@property (nonatomic, strong) RCActivityIndicator *activityIndicator;
@property (nonatomic, strong) NSString *connectionFailedMsg;
@property (nonatomic, assign) BOOL debugMode;

- (id)init;
- (void)GETData:(NSURL*)apiMethod;
- (void)POSTData:(NSURL*)apiMethod withData:(NSData*)data;

- (NSURL*)createApiUrlForMethod:(NSString*)type;
- (NSURL*)createApiUrlForMethodWithoutApiKey:(NSString*)type;
- (NSDictionary*)getJSONObjectsFromData:(NSData*)data;
- (NSString*)apiBaseString;
//- (NSString*)apiToken;
- (void)responseErrorHandling:(int)code;

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

//DataManager Classes which inherit form this baseclass must conform
//to this protocoll
@protocol DataManagerBaseSubclassDelegate

@required
- (id)createDataStructure:(NSData*)data;

@end

