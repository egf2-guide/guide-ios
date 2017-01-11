//
//  MainTabBarController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

#import "MainTabBarController.h"
#import "EGF2.h"

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[Graph shared] userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isKindOfClass:[EGFUser class]]) {
            NSString * userId = ((EGFUser *)object).id;
            
            [[Graph shared] objectsForSource:userId edge:@"roles" completion:^(NSArray * objects, NSInteger count, NSError * error) {
                if (objects) {
                    for (NSObject * object in objects) {
                        if ([object isMemberOfClass:[EGFAdminRole class]]) {
                            [self showOffensivePostTab];
                            break;
                        }
                    }
                }
            }];
        }
    }];
}

- (void)showOffensivePostTab {
    UIViewController * controller = [self.storyboard instantiateViewControllerWithIdentifier:@"OffensivePosts"];
    NSMutableArray * controllers = [NSMutableArray arrayWithArray:self.viewControllers];
    controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Offensive Posts" image:[UIImage imageNamed:@"tab_offensive_posts"] tag:0];
    [controllers insertObject:controller atIndex:1];
    self.viewControllers = controllers;
}
@end
