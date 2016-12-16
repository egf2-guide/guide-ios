//
//  SimpleFileManager.h
//  GuideObjC
//
//  Created by LuzanovRoman on 14.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGF2.h"

@interface SimpleFileManager : NSObject
+ (SimpleFileManager *)sharedInstance;

- (void)imageWithFile:(EGFFile *)file completion:(void (^) (UIImage *image, BOOL fromCache))completion;
- (void)deleteAllFiles;
@end
