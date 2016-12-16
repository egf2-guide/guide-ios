//
//  FileImageView.h
//  GuideObjC
//
//  Created by LuzanovRoman on 16.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGF2.h"

@interface FileImageView : UIImageView
@property (nonatomic, retain) IBInspectable EGFFile *file;
@end
