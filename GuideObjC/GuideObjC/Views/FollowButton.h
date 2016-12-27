//
//  FollowButton.h
//  GuideObjC
//
//  Created by LuzanovRoman on 27.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGF2.h"

@interface FollowButton : UIButton
@property (weak, nonatomic) EGFUser *user;

- (void)checkFollowState;
@end
