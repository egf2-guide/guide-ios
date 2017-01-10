//
//  EmailVerificationController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 10.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

#import "EmailVerificationController.h"
#import "ProgressController.h"

@interface EmailVerificationController ()
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@end

@implementation EmailVerificationController

- (IBAction)resendEmailVerification:(id)sender {
    _errorLabel.text = nil;
    
    [ProgressController show];
    [self.graph resendEmailVerificationWithCompletion:^(id object, NSError * error) {
        [ProgressController hide];
        
        if (error) {
            _errorLabel.text = error.localizedFailureReason;
        }
        else {
            NSString *title = @"Email has been successfully sent";
            NSString *message = @"Please check your email";
            UIAlertController * controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popToRootViewControllerAnimated:true];
            }];
            [controller addAction:ok];
            [self presentViewController:controller animated:true completion:nil];
        }
    }];
}

@end
