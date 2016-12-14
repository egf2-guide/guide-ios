//
//  EGFHumanName+Additions.m
//  GuideObjC
//
//  Created by LuzanovRoman on 14.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "EGFHumanName+Additions.h"

@implementation EGFHumanName (Additions)

- (NSString *)fullName {
    NSString * fullName = @"";
    
    if (self.family) {
        fullName = self.family;
    }
    if (self.given) {
        fullName = fullName.length == 0 ? self.given : [fullName stringByAppendingFormat:@" %@", self.given];
    }
    return fullName;
}
@end
