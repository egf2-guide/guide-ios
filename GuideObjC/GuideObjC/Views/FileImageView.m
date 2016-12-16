//
//  FileImageView.m
//  GuideObjC
//
//  Created by LuzanovRoman on 16.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "FileImageView.h"
#import "SimpleFileManager.h"
#import "UIColor+Additions.h"

@interface FileImageView ()
@property (retain, nonatomic) UIActivityIndicatorView *indicator;
@end

@implementation FileImageView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicator.translatesAutoresizingMaskIntoConstraints = false;
        _indicator.color = [UIColor hexColor:0x5E66B1];
        [self addSubview:_indicator];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_indicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_indicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    return self;
}

- (void)setFile:(EGFFile *)file {
    _file = file;
    
    self.image = nil;
    [self.indicator stopAnimating];
    
    if (!file) {
        return;
    }
    [self.indicator startAnimating];
    
    __block EGFFile * theFile = file;
    
    [[SimpleFileManager sharedInstance] imageWithFile:file completion:^(UIImage *image, BOOL fromCache) {
        // We must be ensure we show appropriate image
        if (theFile != _file) {
            return;
        }
        self.image = image;
        [self.indicator stopAnimating];
        
        if (image && !fromCache) {
            self.alpha = 0;
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 1;
            } completion:^(BOOL finished) {
                self.alpha = 1;
            }];
        }
    }];
}
@end
