//
//  BaseTableViewController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _graph = [Graph shared];
}
@end
