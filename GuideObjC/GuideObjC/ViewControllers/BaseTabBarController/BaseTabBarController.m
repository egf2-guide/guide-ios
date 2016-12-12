//
//  BaseTabBarController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseTabBarController.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

- (void)awakeFromNib {
    [super awakeFromNib];
    _graph = [Graph shared];
}
@end
