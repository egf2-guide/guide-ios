//
//  OffensivePosts.m
//  GuideObjC
//
//  Created by LuzanovRoman on 30.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "OffensivePosts.h"

@interface OffensivePosts ()
@property (retain, nonatomic) NSMutableArray <NSString *> *notOffensivePostsIds;
@property (retain, nonatomic) NSMutableArray <NSString *> *offensivePostsIds;
@property (retain, nonatomic) NSMutableArray <NSString *> *checkingIds;
@property (retain, nonatomic) NSMutableArray <NSString *> *addingIds;
@property (retain, nonatomic) NSString *currentUserId;
@property (retain, nonatomic) NSString *edge;
@end

@implementation OffensivePosts

+ (OffensivePosts *)shared {
    static OffensivePosts * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OffensivePosts alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _edge = @"offended";
        _addingIds = [NSMutableArray array];
        _checkingIds = [NSMutableArray array];
        _offensivePostsIds = [NSMutableArray array];
        _notOffensivePostsIds = [NSMutableArray array];
    }
    return self;
}

- (void)startSession {
    [[Graph shared] userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isMemberOfClass:[EGFUser class]]) {
            _currentUserId = ((EGFUser *)object).id;
        }
    }];
}

- (void)stopSession {
    [_notOffensivePostsIds removeAllObjects];
    [_offensivePostsIds removeAllObjects];
    [_checkingIds removeAllObjects];
    [_addingIds removeAllObjects];
    _currentUserId = nil;
}

- (OffensiveState)offensiveStateForPost:(EGFPost*)post {
    if (!post.id || !_currentUserId) {
        return osUnknown;
    }
    if ([_checkingIds containsObject:post.id]) {
        return osUnknown;
    }
    if ([_addingIds containsObject:post.id] || [_offensivePostsIds containsObject:post.id]) {
        return osOffensive;
    }
    if ([_notOffensivePostsIds containsObject:post.id]) {
        return osNotOffensive;
    }
    [_checkingIds addObject:post.id];
    [[Graph shared] doesObjectWithId:_currentUserId existForSource:post.id onEdge:_edge completion:^(BOOL exists, NSError * error) {
        [_checkingIds removeObject:post.id];
        
        if (!error) {
            if (exists) {
                [_offensivePostsIds addObject:post.id];
            }
            else {
                [_notOffensivePostsIds addObject:post.id];
            }
        }
    }];
    return osUnknown;
}

- (void)markAsOffensive:(EGFPost *)post completion:(void (^)())completion {
    if (!post.id || !_currentUserId) {
        completion();
        return;
    }
    [_addingIds addObject:post.id];
    [[Graph shared] addObjectWithId:_currentUserId forSource:post.id toEdge:_edge completion:^(id object, NSError * error) {
        [_addingIds removeObject:post.id];
        
        if (!error) {
            [_offensivePostsIds addObject:post.id];
            [_notOffensivePostsIds removeObject:post.id];
        }
        completion();
    }];
}
@end
