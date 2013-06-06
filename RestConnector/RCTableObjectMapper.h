//
//  RCTableObjectMapper.h
//  RestConnector
//
//  Created by Anna Walser on 6/6/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;

@interface RCTableObjectMapper : NSObject
+ (NSSet*)insertAndGetObjectsFromJSON:(FMDatabase*)DB json:(NSData*)jsonData onJsonRootKey:(NSString*)jsonRootKey
                             forClass:(NSString*)className withMappingDictionary:(NSDictionary*)mapping;
@end
