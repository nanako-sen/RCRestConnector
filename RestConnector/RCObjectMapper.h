//
//  RCObjectMapper.h
//  RestConnector
//
//  Created by Anna Walser on 6/5/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCObjectMapper : NSObject
+ (NSSet*)createObjectFrom:(NSData*)jsonData onJsonRootKey:(NSString*)jsonRootKey
                  forClass:(NSString*)className withMappingDictionary:(NSDictionary*)mapping;
@end
