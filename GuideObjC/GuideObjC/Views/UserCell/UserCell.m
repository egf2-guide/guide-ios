//
//  UserCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "UserCell.h"
#import "EGFHumanName+Additions.h"

@interface UserCell ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@end

@implementation UserCell

- (void)setUser:(EGFUser *)user {
    _user = user;
    _userNameLabel.text = [user.name fullName];
}

- (IBAction)didTapFollowButton:(id)sender {
    if (_user) {
        [_delegate didTapFollowButtonWithUser:_user];
    }
}
@end
