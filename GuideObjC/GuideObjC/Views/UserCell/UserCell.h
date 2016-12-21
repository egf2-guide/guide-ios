//
//  UserCell.h
//  GuideObjC
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGF2.h"

@protocol UserCellDelegate <NSObject>
- (void)didTapFollowButtonWithUser:(EGFUser *)user;
@end

@interface UserCell : UITableViewCell
@property (weak, nonatomic) id<UserCellDelegate> delegate;
@property (weak, nonatomic) EGFUser *user;
@end
