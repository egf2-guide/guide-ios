//
//  PostEditController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 28.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "PostEditController.h"
#import "ProgressController.h"

@interface PostEditController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateButton;
@property (weak, nonatomic) IBOutlet UILabel *placeholder;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation PostEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view layoutIfNeeded];
    _textView.text = _post.desc;
    [self textViewDidChange:_textView];
}

- (IBAction)updatePost:(id)sender {
    _errorLabel.text = nil;
    [self.view endEditing:true];
    
    if (_post.id && _textView.text.length > 0) {
        [ProgressController show];
        [self.graph updateObjectWithId:_post.id parameters:@{@"desc":_textView.text} completion:^(NSObject * object, NSError * error) {
            [ProgressController hide];
            
            if (error) {
                _errorLabel.text = error.localizedFailureReason;
            }
            else {
                [self.navigationController popViewControllerAnimated:true];
            }
        }];
    }
}

- (void)updateSendButton {
    _updateButton.enabled = _textView.text.length > 0 && ![_textView.text isEqual:_post.desc];
}

- (void)textViewDidChange:(UITextView *)textView {
    CGSize size = [_textView sizeThatFits:CGSizeMake(textView.frame.size.width, 1000)];
    CGFloat newHeight = MIN(100, MAX(50, size.height));
    
    if (newHeight != _textViewHeight.constant) {
        _textViewHeight.constant = newHeight;
        [self.view layoutIfNeeded];
        [textView setContentOffset:CGPointMake(0, 0) animated:false];
    }
    _placeholder.hidden = textView.text.length > 0;
    [self updateSendButton];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@"\n"]) {
        [textView resignFirstResponder];
        return false;
    }
    return true;
}
@end
