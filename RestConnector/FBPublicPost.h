//
//  FBPeople.h
//  RestConnector
//
//  Created by Anna Walser on 26/02/13.
//  Copyright (c) 2013 Nanako. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBPublicPost : NSObject {
    NSString *name;
    NSNumber *postId;
    NSArray *likes;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *postId;
@property (nonatomic, strong) NSArray *likes;


@end
