//
//  RCPropertyClassUtil.m
//  RestConnector
//
//  Created by Anna Walser on 6/3/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import "RCPropertyClassUtil.h"
#import "objc/runtime.h"

@interface RCPropertyClassUtil ()

+ (NSString*)DBFieldTypeFor:(NSString*)propType;
@end

@implementation RCPropertyClassUtil

static const char * getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
}


+ (NSDictionary *)classPropsFor:(Class)klass
{
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
//TODO: create another mehtod which gives real property types
            NSString *dbPropType = [self DBFieldTypeFor:propertyType];
            [results setObject:dbPropType forKey:propertyName];
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}

+ (NSString*)DBFieldTypeFor:(NSString*)propType
{
//TODO: find solution for NSarray or dicts data type
    if ([propType isEqualToString:@"NSString"] || [propType isEqualToString:@"NSArray"] 
        || [propType isEqualToString:@"NSDictionary"]) {
        return @"text";
    }
    else if ([propType isEqualToString:@"NSInteger"]) {
        return @"int";
    }
    else if ([propType isEqualToString:@"NSNumber"]) {
        return @"real";
    }
    else if ([propType isEqualToString:@"BOOL"] || [propType isEqualToString:@"NSDate"])
        return @"numeric";
    else
        [NSException raise:@"Unknown dataType" format:@"Can't create database field type of type %@",propType];
    return @"Null";
}


@end
