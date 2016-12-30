//
//  OffensivePostButton.h
//  GuideObjC
//
//  Created by LuzanovRoman on 30.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGF2.h"

@interface OffensivePostButton : UIButton
@property (weak, nonatomic) EGFPost *post;

- (void)checkOffensiveState;
@end
