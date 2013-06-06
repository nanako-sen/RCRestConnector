//
//  RCObjectMappingHelper.h
//  RestConnector
//
//  Created by Anna Walser on 6/6/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import <Foundation/Foundation.h>

id getJsonValueByMappedKey(id mappedValue,NSDictionary*dict);
NSDictionary* getJSONObjectsFromData(NSData* data);
