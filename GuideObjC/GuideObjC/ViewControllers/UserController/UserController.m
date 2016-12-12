//
//  UserController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "UserController.h"

@interface UserController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) EGFUser *currentUser;
@property (retain, nonatomic) EGFUser *changedUser;
@end

@implementation UserController
@synthesize currentUser, changedUser;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isKindOfClass:[EGFUser class]]) {
            EGFUser * user = (EGFUser *)object;
            _firstNameTextField.text = user.name.given;
            _lastNameTextField.text = user.name.family;
            [self setCurrentUser:user];
        }
    }];
}

- (void)setCurrentUser:(EGFUser *)user {
    currentUser = user;
    changedUser = [user copyGraphObject];
    [self userDataDidUpdate];
}

- (IBAction)save:(id)sender {
    [self.view endEditing:true];
    
    [self.graph updateObjectWithId:currentUser.id object:changedUser completion:^(NSObject * object, NSError * error) {
        if ([object isKindOfClass:[EGFUser class]]) {
            [self setCurrentUser:(EGFUser *)object];
        }
    }];
}

- (IBAction)textDidChange:(id)sender {
    [self userDataDidUpdate];
}

- (void)userDataDidUpdate {
    if (!changedUser.name) {
        changedUser.name = [[EGFHumanName alloc] init];
    }
    changedUser.name.given = _firstNameTextField.text;
    changedUser.name.family = _lastNameTextField.text;
    _saveButton.enabled = ![currentUser isEqualWithGraphObject:changedUser];
}
@end
