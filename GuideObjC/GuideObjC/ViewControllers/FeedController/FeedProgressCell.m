//
//  FeedProgressCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 14.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "FeedProgressCell.h"

@interface FeedProgressCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellHeight;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@end

@implementation FeedProgressCell

- (void)setIndicatorIsHidden:(BOOL)indicatorIsHidden {
    _indicatorIsHidden = indicatorIsHidden;
    _activityIndicatorView.hidden = indicatorIsHidden;
    _cellHeight.constant = indicatorIsHidden ? 1 : 40;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [_activityIndicatorView startAnimating];
}
@end
