//
//  UIViewController+Additions.m
//  GuideObjC
//
//  Created by LuzanovRoman on 26.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "UIViewController+Additions.h"

@implementation UIViewController (Additions)

- (void)showConfirmWithTitle:(NSString *)title message:(NSString *)message action:(void (^)())confirmAction {
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        confirmAction();
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:true completion:nil];
}
@end
