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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttomOffset;
@end

@implementation BaseViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _graph = [Graph shared];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeEventName:(NSString *)name withSelector:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:name object:nil];
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

- (CGFloat)keyboardHeightFromNotification:(NSNotification *)notification {
    NSValue * value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    return [value CGRectValue].size.height;
}

- (CGFloat)animationDurationFromNotification:(NSNotification *)notification {
    NSNumber * value = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    return [value doubleValue];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (_buttomOffset) {
        _buttomOffset.constant = [self keyboardHeightFromNotification:notification];
        [UIView animateWithDuration:[self animationDurationFromNotification:notification] animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (_buttomOffset) {
        _buttomOffset.constant = 0;
        [UIView animateWithDuration:[self animationDurationFromNotification:notification] animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}
@end
