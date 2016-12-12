//
//  BaseNavigationController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)awakeFromNib {
    [super awakeFromNib];
    _graph = [Graph shared];
}

@end
