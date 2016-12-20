//
//  OCDesignableButton.h
//  GuideObjC
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface OCDesignableButton : UIButton
@property (nonatomic) IBInspectable UIColor *backgroundNormalColor;
@property (nonatomic) IBInspectable UIColor *backgroundHighlightColor;
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@end
