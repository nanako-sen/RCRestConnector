//
//  RCObjectMapper.h
//  RestConnector
//
//  Created by Anna Walser on 6/5/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCDBManager.h"

@interface RCObjectMapper : RCDBManager
+ (id)sharedInstance;
- (NSArray*)createObjectsFromJSON:(NSData*)jsonData onJsonRootKey:(NSString*)jsonRootKey
                  forClass:(NSString*)className withMappingDictionary:(NSDictionary*)mapping;

- (NSArray*)insertAndGetObjectsFromJSON:(NSData*)jsonData onJsonRootKey:(NSString*)jsonRootKey
                               forClass:(NSString*)className withMappingDictionary:(NSDictionary*)mapping;
@end
