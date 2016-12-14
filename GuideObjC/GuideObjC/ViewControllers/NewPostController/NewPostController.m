//
//  NewPostController.m
//  GuideObjC
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "NewPostController.h"
#import "ProgressController.h"

@interface NewPostController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *placeholder;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (retain, nonatomic) UIImage *postImage;
@property (retain, nonatomic) NSString *currentUserId;
@end

@implementation NewPostController
@synthesize postImage, currentUserId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.graph userObjectWithCompletion:^(NSObject * object, NSError * error) {
        if ([object isKindOfClass:[EGFUser class]]) {
            currentUserId = ((EGFUser *)object).id;
        }
    }];
}

- (void)showError:(NSError *)error {
    if (error) {
        _errorLabel.text = error.localizedFailureReason;
    }
    else {
        _errorLabel.text = @"An unknown error";
    }
}

- (IBAction)createPost:(id)sender {
    _errorLabel.text = nil;
    
    if (currentUserId && postImage) {
        NSData * imageData = UIImageJPEGRepresentation(postImage, 0.75);
        NSString * desc = _textView.text;
        
        [ProgressController show];
        [self.graph uploadImageWithData:imageData title:@"Photo" mimeType:@"image/jpeg" kind:@"image" completion:^(NSObject * object, NSError * error) {
            if ([object isKindOfClass:[EGFFile class]]) {
                NSDictionary * parameters = @{@"image":((EGFFile *)object).id, @"desc":desc, @"object_type":@"post"};
                [self.graph createObjectWithParameters:parameters forSource:currentUserId onEdge:@"posts" completion:^(NSObject * object, NSError * error) {
                    if ([object isKindOfClass:[EGFPost class]]) {
                        [self.navigationController popViewControllerAnimated:true];
                    }
                    else {
                        [self showError:error];
                    }
                    [ProgressController hide];
                }];
            }
            else {
                [self showError:error];
                [ProgressController hide];
            }
        }];
    }
}

- (IBAction)imageButtonDidTouchUp:(id)sender {
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [controller addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getImageWithSource:UIImagePickerControllerSourceTypeCamera];
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"From Camera Roll" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getImageWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:true completion:nil];
}

- (void)getImageWithSource:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController * controller = [[UIImagePickerController alloc] init];
    controller.sourceType = sourceType;
    controller.delegate = self;
    [self presentViewController:controller animated:true completion:nil];
}

- (void)updateSendButton {
    _sendButton.enabled = postImage != nil && _textView.text.length > 0;
}

// MARK:- UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {

    CGSize size = [_textView sizeThatFits:CGSizeMake(textView.frame.size.width, 1000)];
    CGFloat newHeight = MIN(100, MAX(50, size.height));
    
    if (newHeight != _textViewHeight.constant) {
        _textViewHeight.constant = newHeight;
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

// MARK:- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:true completion:^{
        UIImage * image = info[UIImagePickerControllerOriginalImage];
        
        if (image) {
            CGFloat maxWidth = self.view.frame.size.width - 40;
            CGFloat imageRatio = image.size.width / image.size.height;
            
            _imageWidth.constant = MIN(maxWidth, image.size.width);
            _imageHeight.constant = _imageWidth.constant / imageRatio;
            [_imageButton setImage:image forState:UIControlStateNormal];
            [_imageButton setTitle:nil forState:UIControlStateNormal];

            CGFloat imageMaxSize = 800;
            
            if (image.size.width > imageMaxSize || image.size.height > imageMaxSize) {
                CGFloat w = MIN(imageMaxSize, image.size.width);
                CGFloat h = w / imageRatio;
                
                CGImageRef cropImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, w, h));
                self.postImage = [UIImage imageWithCGImage:cropImageRef];
                CGImageRelease(cropImageRef);
            }
            else {
                self.postImage = image;
            }
            [self updateSendButton];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}
@end
