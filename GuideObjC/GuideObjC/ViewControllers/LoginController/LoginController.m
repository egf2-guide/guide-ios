//
//  LoginController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "LoginController.h"
#import "ProgressController.h"

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@end

@implementation LoginController


- (IBAction)login:(id)sender {
    _errorLabel.text = nil;
    
    NSString * email = _emailTextField.text;
    NSString * password = _passwordTextField.text;
    
    if (email.length == 0 || password.length == 0) {
        _errorLabel.text = @"Enter email and password";
        return;
    }
    [self.view endEditing:true];
    
    [ProgressController show];
    [self.graph loginWithEmail:email password:password completion:^(id object, NSError * error) {
        
        if (error) {
            self.errorLabel.text = error.localizedFailureReason;
            [ProgressController hide];
        }
        else {
            [self getUserObject];
        }
    }];
}

- (void)getUserObject {
    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        [ProgressController hide];
        
        if (error) {
            self.errorLabel.text = [NSString stringWithFormat:@"Can't get user. %@", error.localizedDescription];
        }
        else {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
}

// MARK:- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:true];
    return true;
}
@end

