//
//  OffensivePostCell.h
//  GuideObjC
//
//  Created by LuzanovRoman on 09.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileImageView.h"
#import "EGF2.h"

@protocol OffensivePostCellDelegate <NSObject>
- (void)deletePost:(EGFPost *)post;
- (void)confirmAsOffensive:(EGFPost *)post;
@end

@interface OffensivePostCell : UITableViewCell
@property (weak, nonatomic) id <OffensivePostCellDelegate> delegate;
@property (weak, nonatomic) EGFPost *post;

+ (CGFloat)heightForPost:(EGFPost *)post;
@end
