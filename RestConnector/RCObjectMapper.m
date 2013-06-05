//
//  RCObjectMapper.m
//  RestConnector
//
//  Created by Anna Walser on 6/5/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import "RCObjectMapper.h"

@interface RCObjectMapper ()

+ (id)getJsonValueByMapedKey:(id)mappedValue inJsonDictionary:(NSDictionary*)dict;
+ (NSDictionary*)getJSONObjectsFromData:(NSData*)data;

@end

@implementation RCObjectMapper

//http://stackoverflow.com/questions/5197446/nsmutablearray-force-the-array-to-hold-specific-object-type-only
//TODO: nested json values NSArray *responseArray = [[[responseString JSONValue] objectForKey:@"d"] objectForKey:@"results"]; - done

+ (NSSet*)createObjectFrom:(NSData*)jsonData onJsonRootKey:(NSString*)jsonRootKey
forClass:(NSString*)className withMappingDictionary:(NSDictionary*)mapping
{
    //_mappingDictionary = @{@"likes": @{@"likes":@{@"data":@"name"}}, @"postId":@"id", @"name":@{@"from": @"name"}};
    
    NSMutableSet *finalArray = [[NSMutableSet alloc] init];
    NSDictionary *resultDict = [self getJSONObjectsFromData:jsonData];
    
    if (resultDict && finalArray) {
        NSDictionary *jsonDict = [resultDict objectForKey:jsonRootKey];
        for (NSDictionary *dict in jsonDict)
        {
            id object = [[NSClassFromString(className) alloc] init];
            
            for(NSString *realKey in [mapping allKeys])
            {
                id mappedValue = [mapping valueForKey: realKey];
                id restValue = [self getJsonValueByMapedKey:mappedValue inJsonDictionary:dict];
                
                [object setValue:restValue forKey:realKey];
            }
            [finalArray addObject:object];
        }
    }
    NSSet * arr = [finalArray copy]; //returning NSarray instead of mutable - copy makes an immutable copy
    return arr;
}

+ (id)getJsonValueByMapedKey:(id)mappedValue inJsonDictionary:(NSDictionary*)dict
{
    id jsonValue;
    if ([mappedValue isKindOfClass:[NSString class]])
        jsonValue = [dict valueForKey:mappedValue];
    else if ([mappedValue isKindOfClass:[NSDictionary class]]) {
        NSString *mappedSubKey = [mappedValue allKeys][0];
        NSDictionary *nestedDict = [dict valueForKey:mappedSubKey];
        NSString *wantedMappedValue = [mappedValue valueForKey:mappedSubKey];
        jsonValue = (wantedMappedValue == nil) ? nil : [self getJsonValueByMapedKey:wantedMappedValue inJsonDictionary:nestedDict];
    }
    return jsonValue;
}

+ (NSDictionary*)getJSONObjectsFromData:(NSData*)data
{
    
    NSError*    error       = nil;
    NSDictionary*    resultData = nil;
    resultData  = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error){
        NSLog(@"JSON Error: %@ %@", error, [error userInfo]);
        resultData = nil;
    }
    return resultData;
    
}

@end
