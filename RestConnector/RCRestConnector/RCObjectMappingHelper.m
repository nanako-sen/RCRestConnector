//
//  RCObjectMappingHelper.m
//  RestConnector
//
//  Created by Anna Walser on 6/6/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "RCObjectMappingHelper.h"



id getJsonValueByMappedKey(id mappedValue,NSDictionary*dict)
{
    id jsonValue;
    if ([mappedValue isKindOfClass:[NSString class]]) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            jsonValue = [dict valueForKey:mappedValue];
        }else if ([dict isKindOfClass:[NSArray class]]) {
#warning - Hack to make it work with array or not - needs to get done propperly but working
            NSArray *arr = (NSArray*)dict;
            jsonValue = [arr objectAtIndex: [mappedValue intValue]];
        }
        
    }
    else if ([mappedValue isKindOfClass:[NSDictionary class]]) {
        NSString *mappedSubKey = [mappedValue allKeys][0];
        NSDictionary *nestedDict = [dict valueForKey:mappedSubKey];
        NSString *wantedMappedValue = [mappedValue valueForKey:mappedSubKey];
        jsonValue = (wantedMappedValue == nil) ? nil : getJsonValueByMappedKey(wantedMappedValue,nestedDict);
    }
    
    if (jsonValue == nil) {
        jsonValue = @"NULL";
    }
    
    return jsonValue;
}

NSDictionary* getJSONObjectsFromData(NSData* data)
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


