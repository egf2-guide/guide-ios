//
//  Follows.h
//  GuideObjC
//
//  Created by LuzanovRoman on 23.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGF2.h"

typedef enum FollowState : NSUInteger {
    isMe,
    isUnknown,
    isFollow,
    isNotFollow
} FollowState;

@interface Follows : NSObject

+ (Follows *)shared;

- (void)startObserving;
- (void)stopObserving;
- (FollowState)followStateForUser:(EGFUser*)user;
- (void)followUser:(EGFUser *)user completion:(void (^)())completion;
- (void)unfollowUser:(EGFUser *)user completion:(void (^)())completion;
@end
