//
//  BaseViewController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseViewController.h"
#import "UIColor+Additions.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _graph = [Graph shared];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
}

- (UIToolbar *)toolbarWithButton:(NSString *)title selector:(SEL)selector {
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:selector];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    button.tintColor = [UIColor hexColor:0x5E66B1];
    toolbar.items = @[space, button];
    return toolbar;
}
@end
