//
//  FollowButton.m
//  GuideObjC
//
//  Created by LuzanovRoman on 27.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "FollowButton.h"
#import "Follows.h"

@implementation FollowButton

- (void)setUser:(EGFUser *)user {
    _user = user;
    [self checkFollowState];
}

- (void)checkFollowState {
    [self setImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
    self.hidden = false;
    
    if (_user) {
        __weak FollowButton *weakSelf = self;
        
        switch ([[Follows shared] followStateForUser:_user]) {
            case isMe:
                self.hidden = true;
                break;
                
            case isFollow:
                [self setImage:[UIImage imageNamed:@"follow_added"] forState:UIControlStateNormal];
                break;
                
            case isNotFollow:
                break;
                
            case isUnknown:
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [weakSelf checkFollowState];
                });
                break;
        }
    }
}
@end
