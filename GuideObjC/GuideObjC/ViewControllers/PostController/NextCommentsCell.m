//
//  NextCommentsCell.m
//  GuideObjC
//
//  Created by LuzanovRoman on 19.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "NextCommentsCell.h"

@interface NextCommentsCell ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@end

@implementation NextCommentsCell

- (void)setIndicatorIsAnimated:(BOOL)indicatorIsAnimated {
    _indicatorIsAnimated = indicatorIsAnimated;
    
    if (indicatorIsAnimated) {
        [_activityIndicatorView startAnimating];
    }
    else {
        [_activityIndicatorView stopAnimating];
    }
}

- (IBAction)showNext:(id)sender {
    [self.delegate showNext];
    self.indicatorIsAnimated = true;
}
@end
