//
//  ResetPasswordController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 20.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "ResetPasswordController.h"
#import "ProgressController.h"

@interface ResetPasswordController ()
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@end

@implementation ResetPasswordController

- (IBAction)changePassword:(id)sender {
    _errorLabel.text = nil;
    
    if (_tokenTextField.text.length == 0 || _passwordTextField.text.length == 0 || _confirmTextField.text.length == 0) {
        return;
    }
    if (![_passwordTextField.text isEqual:_confirmTextField.text]) {
        _errorLabel.text = @"New password and confirm password does not match";
        return;
    }
    [self.view endEditing:true];
    
    [ProgressController show];
    [self.graph resetPasswordWithToken:_tokenTextField.text newPassword:_passwordTextField.text completion:^(id object, NSError * error) {
        [ProgressController hide];
        
        if (error) {
            _errorLabel.text = error.localizedFailureReason;
        }
        else {
            NSString *title = @"Password has been succesfully changed";
            NSString *message = @"Please use your new password to login";
            UIAlertController * controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popToRootViewControllerAnimated:true];
            }];
            [controller addAction:ok];
            [self presentViewController:controller animated:true completion:nil];
        }
    }];
}

- (IBAction)textDidChange:(UITextField *)sender {
    _resetButton.enabled = _tokenTextField.text.length > 0 && _passwordTextField.text.length > 0 && _confirmTextField.text.length > 0;
}

// MARK:- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}
@end
