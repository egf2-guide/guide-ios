//
//  SimpleFileManager.m
//  GuideObjC
//
//  Created by LuzanovRoman on 14.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "SimpleFileManager.h"

@implementation SimpleFileManager

+ (void)imageWithFile:(EGFFile *)file completion:(void (^) (UIImage *image, BOOL fromCache))completion {
    if (!file || !file.id || !file.url) {
        completion(nil, false);
        return;
    }
    NSString * cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURL * url = [[NSURL alloc] initWithString:file.url];
    NSURL * localUrl = [NSURL fileURLWithPath:[cachePath stringByAppendingFormat:@"/%@",file.id]];

    if ([localUrl checkResourceIsReachableAndReturnError:nil]) {
        completion([UIImage imageWithData:[NSData dataWithContentsOfURL:localUrl]], true);
    }
    else {
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                
                UIImage * image = [UIImage imageWithData:data];
                [data writeToURL:localUrl atomically:false];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    completion(image, false);
                });
            });
        }] resume];
    }
}
@end
