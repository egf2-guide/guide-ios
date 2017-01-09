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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeEventName:(NSString *)name withSelector:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:name object:nil];
}

- (void)observeForSource:(NSString *)source eventName:(NSString *)name withSelector:(SEL)selector  {
    NSObject * object = [[Graph shared] notificationObjectForSource:source];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:name object:object];
}
@end
