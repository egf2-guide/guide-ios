//
//  OffendedUserCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

#import "OffendedUserCell.h"
#import "EGFHumanName+Additions.h"

@interface OffendedUserCell ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@end

@implementation OffendedUserCell

- (void)setOffendedUser:(EGFUser *)offendedUser {
    _offendedUser = offendedUser;
    _userNameLabel.text = [offendedUser.name fullName];
}
@end
