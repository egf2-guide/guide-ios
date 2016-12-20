//
//  ChangePasswordController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 20.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "ChangePasswordController.h"
#import "ProgressController.h"

@interface ChangePasswordController ()
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *theNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *changeButton;
@end

@implementation ChangePasswordController

- (IBAction)changePassword:(id)sender {
    _errorLabel.text = nil;
    
    if (_oldPassword.text.length == 0 || _theNewPassword.text.length == 0 || _confirmPassword.text.length == 0) {
        return;
    }
    if (_theNewPassword.text != _confirmPassword.text) {
        _errorLabel.text = @"New password and confirm password does not match";
        return;
    }
    [self.view endEditing:true];
    
    [ProgressController show];
    [self.graph changeWithOldPassword:_oldPassword.text withNewPassword:_theNewPassword.text completion:^(id object, NSError * error) {
        [ProgressController hide];
        
        if (error) {
            _errorLabel.text = error.localizedFailureReason;
        }
        else {
            UIAlertController * controller = [UIAlertController alertControllerWithTitle:@"Success" message:@"Password has been changed" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:true];
            }];
            [controller addAction:ok];
            [self presentViewController:controller animated:true completion:nil];
        }
    }];
}

- (IBAction)textDidChange:(UITextField *)sender {
    _changeButton.enabled = _oldPassword.text.length > 0 && _theNewPassword.text.length > 0 && _confirmPassword.text.length > 0;
}

// MARK:- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}
@end
