//
//  FBGroup.h
//  RestConnector
//
//  Created by Anna Walser on 6/11/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBGroup : NSObject {
    NSNumber *groupId;
    NSString *name;
}
@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, strong) NSString *name;

@end
