//
//  RegisterController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "RegisterController.h"

@interface RegisterController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewButtom;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *dobTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (retain, nonatomic) UIDatePicker *birthDatePicker;
@property (retain, nonatomic) NSDate *birthDate;
@end

@implementation RegisterController
@synthesize birthDatePicker, birthDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    birthDatePicker = [[UIDatePicker alloc] init];
    birthDatePicker.datePickerMode = UIDatePickerModeDate;
    [birthDatePicker addTarget:self action:@selector(birthDatePickerDidChange:) forControlEvents:UIControlEventValueChanged];
    _dobTextField.inputView = birthDatePicker;
    _dobTextField.inputAccessoryView = [self toolbarWithButton:@"Done" selector:@selector(didPressDoneButton)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)registerUser:(id)sender {
    _errorLabel.text = nil;
    
    NSString * firstName = _firstNameTextField.text;
    NSString * lastName = _lastNameTextField.text;
    NSString * password = _passwordTextField.text;
    NSString * email = _emailTextField.text;
    
    if (firstName.length == 0 || lastName.length == 0 || password.length == 0 || email.length == 0 || !birthDate) {
        _errorLabel.text = @"All fields are required";
    }
    [self.graph registerWithFirstName:firstName lastName:lastName email:email dateOfBirth:birthDate password:password completion:^(id object, NSError * error) {
        if (error) {
            _errorLabel.text = error.localizedFailureReason;
        }
        else {
            [self getUserObject];
        }
    }];
}

- (void)getUserObject {
    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if (error) {
            _errorLabel.text = [NSString stringWithFormat:@"Can't get user. %@", error.localizedDescription];
        }
        else {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
}

- (void)didPressDoneButton {
    [self.view endEditing:true];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat keyboardHeight = [(NSValue *)notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat duration = [(NSNumber *)notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    _scrollViewButtom.constant = keyboardHeight;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGFloat duration = [(NSNumber *)notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    _scrollViewButtom.constant = 0;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)birthDatePickerDidChange:(UIDatePicker *)sender {
    [self updateBirthDateWithDate:sender.date];
}

- (void)updateBirthDateWithDate:(NSDate *)date {
    birthDate = date;
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    _dobTextField.text = [dateFormatter stringFromDate:date];
}

// MARK:- UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _dobTextField) {
        birthDatePicker.date = birthDate ? birthDate : [NSDate date];
    }
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _dobTextField) {
        [self updateBirthDateWithDate:birthDatePicker.date];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:true];
    return true;
}
@end
