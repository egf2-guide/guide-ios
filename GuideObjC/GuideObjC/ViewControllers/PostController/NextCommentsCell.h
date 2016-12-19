//
//  NextCommentsCell.h
//  GuideObjC
//
//  Created by LuzanovRoman on 19.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NextCommentsCellDelegate <NSObject>
- (void)showNext;
@end

@interface NextCommentsCell : UITableViewCell
@property (assign, nonatomic) BOOL indicatorIsAnimated;
@property (weak, nonatomic) id<NextCommentsCellDelegate> delegate;
@end
