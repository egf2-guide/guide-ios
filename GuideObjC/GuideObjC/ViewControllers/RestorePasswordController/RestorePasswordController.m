//
//  RestorePasswordController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 20.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "RestorePasswordController.h"
#import "ProgressController.h"

@interface RestorePasswordController ()
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@end

@implementation RestorePasswordController

- (IBAction)restorePassword:(id)sender {
    _errorLabel.text = nil;
    
    if (_emailTextField.text.length == 0) {
        return;
    }
    [self.view endEditing:true];
    
    [ProgressController show];
    [self.graph restorePasswordWithEmail:_emailTextField.text completion:^(id object, NSError * error) {
        [ProgressController hide];
        
        if (error) {
            _errorLabel.text = error.localizedFailureReason;
        }
        else {
            [self performSegueWithIdentifier:@"ResetPassword" sender:nil];
        }
    }];
}

- (IBAction)textDidChange:(UITextField *)sender {
    _restoreButton.enabled = _emailTextField.text.length > 0;
}

// MARK:- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}
@end
