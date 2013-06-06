//
//  RCObjectMapper.m
//  RestConnector
//
//  Created by Anna Walser on 6/5/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import "RCObjectMapper.h"
#import "RCObjectMappingHelper.h"

@interface RCObjectMapper ()


@end

@implementation RCObjectMapper

//http://stackoverflow.com/questions/5197446/nsmutablearray-force-the-array-to-hold-specific-object-type-only
//TODO: nested json values NSArray *responseArray = [[[responseString JSONValue] objectForKey:@"d"] objectForKey:@"results"]; - done

+ (NSSet*)createObjectsFromJSON:(NSData*)jsonData onJsonRootKey:(NSString*)jsonRootKey
forClass:(NSString*)className withMappingDictionary:(NSDictionary*)mapping
{
    //_mappingDictionary = @{@"likes": @{@"likes":@{@"data":@"name"}}, @"postId":@"id", @"name":@{@"from": @"name"}};
    
    NSMutableSet *finalArray = [[NSMutableSet alloc] init];
    NSDictionary *resultDict = getJSONObjectsFromData(jsonData);
    
    if (resultDict && finalArray) {
        NSDictionary *jsonDict = [resultDict objectForKey:jsonRootKey];
        for (NSDictionary *dict in jsonDict)
        {
            id object = [[NSClassFromString(className) alloc] init];
            
            for(NSString *realKey in [mapping allKeys])
            {
                id mappedValue = [mapping valueForKey: realKey];
                id restValue = getJsonValueByMappedKey(mappedValue,dict);
                
                [object setValue:restValue forKey:realKey];
            }
            [finalArray addObject:object];
        }
    }
    NSSet * arr = [finalArray copy]; //returning NSarray instead of mutable - copy makes an immutable copy
    return arr;
}


#pragma mark - common methods


@end
