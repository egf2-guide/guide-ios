//
//  PostEditController.h
//  GuideObjC
//
//  Created by LuzanovRoman on 28.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseViewController.h"
#import "EGF2.h"

@interface PostEditController : BaseViewController <UITextViewDelegate>
@property (retain, nonatomic) EGFPost *post;
@end
