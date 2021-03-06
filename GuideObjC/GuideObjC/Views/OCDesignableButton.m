//
//  OCDesignableButton.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "OCDesignableButton.h"
#import "UIImage+Additions.h"

@implementation OCDesignableButton

- (void)setBackgroundNormalColor:(UIColor *)backgroundNormalColor {
    _backgroundNormalColor = backgroundNormalColor;
    
    if (backgroundNormalColor) {
        [self setBackgroundImage:[UIImage imageWithColor:backgroundNormalColor] forState:UIControlStateNormal];
    }
}

- (void)setBackgroundDisableColor:(UIColor *)backgroundDisableColor {
    _backgroundDisableColor = backgroundDisableColor;
    
    if (backgroundDisableColor) {
        [self setBackgroundImage:[UIImage imageWithColor:backgroundDisableColor] forState:UIControlStateDisabled];
    }
}

- (void)setBackgroundHighlightColor:(UIColor *)backgroundHighlightColor {
    _backgroundHighlightColor = backgroundHighlightColor;
    
    if (backgroundHighlightColor) {
        [self setBackgroundImage:[UIImage imageWithColor:backgroundHighlightColor] forState:UIControlStateHighlighted];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}
@end
