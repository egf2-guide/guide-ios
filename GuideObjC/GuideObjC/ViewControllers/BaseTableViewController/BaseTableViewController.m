//
//  BaseTableViewController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseTableViewController.h"
#import "UIColor+Additions.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _graph = [Graph shared];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor hexColor:0x5E66B1];
}
@end
