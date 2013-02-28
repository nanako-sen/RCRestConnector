//
//  FBPeople.m
//  RestConnector
//
//  Created by Anna Walser on 26/02/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import "FBPublicPost.h"

@implementation FBPublicPost

@synthesize name, postId;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super init])) {
        self.name = [dictionary objectForKey:@"name"];
        self.postId = [dictionary objectForKey:@"id"];
    }
    
    return self;
}


@end
