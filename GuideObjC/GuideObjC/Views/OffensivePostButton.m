//
//  OffensivePostButton.m
//  GuideObjC
//
//  Created by LuzanovRoman on 30.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "OffensivePostButton.h"
#import "OffensivePosts.h"

@implementation OffensivePostButton

- (void)setPost:(EGFPost *)post {
    _post = post;
    [self checkOffensiveState];
}

- (void)checkOffensiveState {
    self.tintColor = [UIColor whiteColor];
    
    if (_post) {
        __weak OffensivePostButton *weakSelf = self;
        
        switch ([[OffensivePosts shared] offensiveStateForPost:_post]) {
            case osOffensive:
                self.tintColor = [UIColor yellowColor];
                break;

            case osNotOffensive:
                break;
                
            case osUnknown:
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [weakSelf checkOffensiveState];
                });
                break;
        }
    }
}
@end
