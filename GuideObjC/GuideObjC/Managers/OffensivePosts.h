//
//  OffensivePosts.h
//  GuideObjC
//
//  Created by LuzanovRoman on 30.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGF2.h"

typedef enum OffensiveState : NSUInteger {
    osNotOffensive,
    osOffensive,
    osUnknown
} OffensiveState;

@interface OffensivePosts : NSObject
+ (OffensivePosts *)shared;

- (void)startSession;
- (void)stopSession;

- (OffensiveState)offensiveStateForPost:(EGFPost*)post;
- (void)markAsOffensive:(EGFPost *)post completion:(void (^)())completion;
@end
