//
//  BaseTabBarController.h
//  GuideObjC
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGF2.h"

@interface BaseTabBarController : UITabBarController
@property (nonatomic, weak) EGF2Graph * graph;
@end
