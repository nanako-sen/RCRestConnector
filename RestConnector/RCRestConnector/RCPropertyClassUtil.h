//
//  RCPropertyClassUtil.h
//  RestConnector
//
//  Created by Anna Walser on 6/3/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCPropertyClassUtil : NSObject

+ (NSDictionary *)classPropsFor:(Class)klass;

@end
