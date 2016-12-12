//
//  MainTabBarController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "MainTabBarController.h"
#import "InitController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!self.graph.isAuthorized && [self.navigationController isMemberOfClass:[InitController class]]) {
        ((InitController *)self.navigationController).viewControllers = @[];
    }
}
@end
