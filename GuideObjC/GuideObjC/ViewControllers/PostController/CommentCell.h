//
//  CommentCell.h
//  GuideObjC
//
//  Created by LuzanovRoman on 19.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGF2.h"

@protocol CommentCellDelegate <NSObject>
- (NSString *)authorizedUserId;
- (void)deleteComment:(EGFComment *)comment;
@end

@interface CommentCell : UITableViewCell

+ (CGFloat)heightForComment:(EGFComment *)comment;

@property (weak, nonatomic) id <CommentCellDelegate> delegate;
@property (weak, nonatomic) EGFComment *comment;
@end
