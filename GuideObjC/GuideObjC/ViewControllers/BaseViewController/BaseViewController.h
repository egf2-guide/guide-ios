//
//  BaseViewController.h
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGF2.h"

@interface BaseViewController : UIViewController
@property (nonatomic, weak) EGF2Graph * graph;

- (UIToolbar *)toolbarWithButton:(NSString *)title selector:(SEL)selector;

- (void)observeEventName:(NSString *)name withSelector:(SEL)selector;
@end
