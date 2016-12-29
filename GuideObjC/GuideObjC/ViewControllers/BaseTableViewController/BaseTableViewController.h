//
//  BaseTableViewController.h
//  GuideObjC
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGF2.h"

@interface BaseTableViewController : UITableViewController
@property (nonatomic, weak) EGF2Graph * graph;

- (void)observeEventName:(NSString *)name withSelector:(SEL)selector;
- (void)observeForSource:(NSString *)source eventName:(NSString *)name withSelector:(SEL)selector;
@end
