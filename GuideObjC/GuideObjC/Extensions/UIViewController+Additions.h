//
//  UIViewController+Additions.h
//  GuideObjC
//
//  Created by LuzanovRoman on 26.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Additions)
- (void)showConfirmWithTitle:(NSString *)title message:(NSString *)message action:(void (^)())confirmAction;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
@end
