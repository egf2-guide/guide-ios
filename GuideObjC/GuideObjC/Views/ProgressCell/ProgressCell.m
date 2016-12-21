//
//  ProgressCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "ProgressCell.h"

@interface ProgressCell ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@end

@implementation ProgressCell

- (void)setIndicatorIsHidden:(BOOL)indicatorIsHidden {
    _indicatorIsHidden = indicatorIsHidden;
    _activityIndicatorView.hidden = indicatorIsHidden;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [_activityIndicatorView startAnimating];
}
@end
