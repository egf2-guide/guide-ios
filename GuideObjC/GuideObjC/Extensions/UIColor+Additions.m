//
//  UIColor+Additions.m
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

+ (UIColor *)hexColor:(NSInteger)hexColor {
    CGFloat r = ((CGFloat)((hexColor & 0xFF0000) >> 16)) / 255.0;
    CGFloat g = ((CGFloat)((hexColor & 0x00FF00) >> 8)) / 255.0;
    CGFloat b = ((CGFloat)((hexColor & 0x0000FF) >> 0)) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}
@end
