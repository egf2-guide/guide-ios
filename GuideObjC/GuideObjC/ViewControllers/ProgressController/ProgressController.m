//
//  ProgressController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 13.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "ProgressController.h"

static NSInteger counter = 0;
static ProgressController * controller = nil;

@implementation ProgressController

+ (void)show {
    counter += 1;
    
    if (controller == nil) {
        controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProgressController"];
    }
    UIViewController * topController = [self topController];
    
    if (topController) {
        if (controller.view.superview == nil) {
            [topController.view addSubview:controller.view];
            controller.view.alpha = 0;
        }
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            controller.view.alpha = 1;
        } completion:nil];
    }
}

+ (void)hide {
    if (counter > 0) {
        counter -= 1;
    }
    if (counter == 0 && controller.view.superview != nil) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            controller.view.alpha = 0;
        } completion:^(BOOL finished) {
            if (counter == 0) {
                [controller.view removeFromSuperview];
            }
        }];
    }
}

+ (UIViewController *)topController {
    UIViewController * topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController * presentedViewController = topController.presentedViewController;
    
    while (presentedViewController) {
        topController = presentedViewController;
        presentedViewController = topController.presentedViewController;
    }
    return topController;
}
@end
