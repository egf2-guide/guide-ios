//
//  UserCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "UserCell.h"
#import "EGFHumanName+Additions.h"
#import "Follows.h"

@interface UserCell ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@end

@implementation UserCell

- (void)setUser:(EGFUser *)user {
    _user = user;
    _userNameLabel.text = [user.name fullName];
    [self applyFollowState];
}

- (void)applyFollowState {
    [_followButton setImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
    _followButton.hidden = false;
    
    if (_user) {
        switch ([[Follows shared] followStateForUser:_user]) {
            case isMe:
                _followButton.hidden = true;
                break;
                
            case isFollow:
                [_followButton setImage:[UIImage imageNamed:@"follow_added"] forState:UIControlStateNormal];
                break;
                
            case isNotFollow:
                break;
                
            case isUnknown:
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self applyFollowState];
                });
                break;
        }
    }
}

- (IBAction)didTapFollowButton:(id)sender {
    if (_user) {
        [_delegate didTapFollowButtonWithUser:_user andCell:self];
    }
}
@end
