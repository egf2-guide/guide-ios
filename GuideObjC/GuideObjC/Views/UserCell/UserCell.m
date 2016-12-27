//
//  UserCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "UserCell.h"
#import "EGFHumanName+Additions.h"
#import "FollowButton.h"
#import "Follows.h"

@interface UserCell ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet FollowButton *followButton;
@end

@implementation UserCell

- (void)setUser:(EGFUser *)user {
    _user = user;
    _userNameLabel.text = [user.name fullName];
    _followButton.user = user;
}

- (IBAction)didTapFollowButton:(id)sender {
    if (_user) {
        [_delegate didTapFollowButtonWithUser:_user andCell:self];
    }
}
@end
