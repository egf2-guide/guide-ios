//
//  MoreCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "MoreCell.h"
#import "UIColor+Additions.h"

@implementation MoreCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView * backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [[UIColor hexColor:0x5E66B1] colorWithAlphaComponent:0.25];
    self.selectedBackgroundView = backgroundView;
}
@end
