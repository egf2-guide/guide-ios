//
//  Follows.m
//  GuideObjC
//
//  Created by LuzanovRoman on 23.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "Follows.h"

@interface Follows ()
@property (retain, nonatomic) NSMutableArray <EGFUser *> *users;
@property (retain, nonatomic) NSMutableArray <EGFUser *> *adding;
@property (retain, nonatomic) NSMutableArray <EGFUser *> *removing;
@property (retain, nonatomic) NSString *currentUserId;
@property (retain, nonatomic) NSString *edge;
@property (retain, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL isDownloading;
@property (assign, nonatomic) BOOL isDownloaded;
@property (assign, nonatomic) BOOL isObserving;
@property (assign, nonatomic) NSInteger token;
@end

@implementation Follows

+ (Follows *)shared {
    static Follows * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Follows alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _edge = @"follows";
        _users = [NSMutableArray array];
        _adding = [NSMutableArray array];
        _removing = [NSMutableArray array];
    }
    return self;
}

- (void)startObserving {
    [[Graph shared] userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isMemberOfClass:[EGFUser class]]) {
            EGFUser * user = (EGFUser *)object;
            
            [[Graph shared] addObserver:self selector:@selector(edgeCreated:) name:EGF2NotificationEdgeCreated forSource:user.id andEdge:_edge];
            [[Graph shared] addObserver:self selector:@selector(edgeRemoved:) name:EGF2NotificationEdgeRemoved forSource:user.id andEdge:_edge];
            
            NSObject * object = [[Graph shared] notificationObjectForSource:user.id andEdge:_edge];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(edgeRefreshed) name:EGF2NotificationEdgeLocallyRefreshed object:object];
            _isObserving = true;
            _currentUserId = user.id;
            _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkDownloading) userInfo:nil repeats:true];
            [self loadNextPage];
        }
    }];
}

- (void)stopObserving {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_users removeAllObjects];
    [_adding removeAllObjects];
    [_removing removeAllObjects];
    _currentUserId = nil;
    _isObserving = false;
    _isDownloaded = false;
    [_timer invalidate];
    _timer = nil;
}

- (EGFUser *)findUserWithId:(NSString *)id inArray:(NSArray <EGFUser *>*)array {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", id];
    return [array filteredArrayUsingPredicate:predicate].firstObject;
}

- (BOOL)isUserWithId:(NSString *)id inArray:(NSArray <EGFUser *>*)array {
    return [self findUserWithId:id inArray:array] != nil;
}

- (FollowState)followStateForUser:(EGFUser*)user {
    if (!user.id) {
        return isUnknown;
    }
    if ([user.id isEqual:_currentUserId]) {
        return isMe;
    }
    if ([self isUserWithId:user.id inArray:_adding]) {
        return isFollow;
    }
    if ([self isUserWithId:user.id inArray:_removing]) {
        return isNotFollow;
    }
    if ([self isUserWithId:user.id inArray:_users]) {
        return isFollow;
    }
    return _isDownloaded ? isNotFollow : isUnknown;
}

- (void)followUser:(EGFUser *)user completion:(void (^)())completion {
    if (!user) {
        completion();
        return;
    }
    // Can't add user while removing him
    if ([self isUserWithId:user.id inArray:_removing]) {
        completion();
        return;
    }
    [_adding addObject:user];
    [[Graph shared] addObjectWithId:user.id forSource:_currentUserId toEdge:_edge completion:^(id object, NSError * error) {
        [_adding removeObject:user];
        
        if (!error) {
            [_users insertObject:user atIndex:0];
        }
        completion();
    }];
}

- (void)unfollowUser:(EGFUser *)user completion:(void (^)())completion {
    if (!user) {
        completion();
        return;
    }
    // Can't remove user while adding him
    if ([self isUserWithId:user.id inArray:_adding]) {
        completion();
        return;
    }
    [_removing addObject:user];
    [[Graph shared] deleteObjectWithId:user.id forSource:_currentUserId fromEdge:_edge completion:^(id object, NSError * error) {
        [_removing removeObject:user];
        
        if (!error) {
            EGFUser *existUser = [self findUserWithId:user.id inArray:_users];
            
            if (existUser) {
                [_users removeObject:existUser];
            }
        }
        completion();
    }];
}

- (void)edgeCreated:(NSNotification *)notification {
    NSString * userId = notification.userInfo[EGF2EdgeObjectIdInfoKey];
    
    if (userId) {
        // Ignore if user already is in the list
        if ([self isUserWithId:userId inArray:_users]) {
            return;
        }
        [[Graph shared] objectWithId:userId completion:^(NSObject * object, NSError * error) {
            if ([object isMemberOfClass:[EGFUser class]]) {
                [_users insertObject:(EGFUser *)object atIndex:0];
            }
        }];
    }
}

- (void)edgeRemoved:(NSNotification *)notification {
    NSString * userId = notification.userInfo[EGF2EdgeObjectIdInfoKey];
    EGFUser * user = [self findUserWithId:userId inArray:_users];
    [_users removeObject:user];
}

- (void)edgeRefreshed {
    _token += 1;
    _isDownloaded = false;
    [_users removeAllObjects];
    [self loadNextPage];
}

- (void)loadNextPage {
    if (!_currentUserId) {
        return;
    }
    NSInteger localToken = _token;

    _isDownloading = true;
    [[Graph shared] objectsForSource:_currentUserId edge:_edge after: _users.lastObject.id completion:^(NSArray *objects, NSInteger count, NSError * error) {
        _isDownloading = false;
        
        if (localToken != _token) {
            return;
        }
        if (objects) {
            [_users addObjectsFromArray:objects];
            
            if (_users.count == count) {
                _isDownloaded = true;
            }
            else {
                [self loadNextPage];
            }
        }
    }];
}

- (void)checkDownloading {
    if (_isDownloading) {
        return;
    }
    if (_isDownloaded) {
        [_timer invalidate];
        _timer = nil;
        return;
    }
    [self loadNextPage];
}
@end
