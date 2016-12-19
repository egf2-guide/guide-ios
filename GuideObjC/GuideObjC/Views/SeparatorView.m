//
//  SeparatorView.m
//  GuideObjC
//
//  Created by LuzanovRoman on 19.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "SeparatorView.h"

@implementation SeparatorView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    for (NSLayoutConstraint *layoutConstraint in self.constraints) {
        if (layoutConstraint.firstAttribute == NSLayoutAttributeHeight) {
            layoutConstraint.constant = 0.5;
            break;
        }
    }
}
@end
