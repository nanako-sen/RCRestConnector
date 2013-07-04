//
//  RCObjectMapper.h
//  RestConnector
//
//  Created by Anna Walser on 6/5/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCDBManager.h"

@interface RCObjectMapper : RCDBManager {
    NSString *cacheFilterPropertyName;
    id cacheFilterValue;
}

@property (nonatomic, retain) NSString *cacheFilterPropertyName;
@property (nonatomic, retain) id cacheFilterValue;

//+ (id)sharedInstance;
//- (id)init;
- (NSArray*)createObjectsFromJSON:(NSData*)jsonData onJsonRootKey:(NSString*)jsonRootKey
                  forClass:(NSString*)className withMappingDictionary:(NSDictionary*)mapping;

- (NSArray*)insertAndCreateObjectsFromJSON:(NSData*)jsonData onJsonRootKey:(NSString*)jsonRootKey
                               forClass:(NSString*)className withMappingDictionary:(NSDictionary*)mapping;
@end
