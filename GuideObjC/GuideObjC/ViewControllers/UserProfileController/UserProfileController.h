//
//  UserProfileController.h
//  GuideObjC
//
//  Created by LuzanovRoman on 27.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseViewController.h"
#import "PostCell.h"
#import "EGF2.h"

@interface UserProfileController : BaseViewController <UITableViewDelegate, UITableViewDataSource, PostCellDelegate>
@property (retain, nonatomic) EGFUser *profileUser;
@end
