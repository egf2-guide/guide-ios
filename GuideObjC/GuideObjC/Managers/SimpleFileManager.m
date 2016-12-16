//
//  SimpleFileManager.m
//  GuideObjC
//
//  Created by LuzanovRoman on 14.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "SimpleFileManager.h"

@implementation SimpleFileManager

+ (SimpleFileManager *)sharedInstance {
    static SimpleFileManager * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SimpleFileManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self cachesPath] withIntermediateDirectories:false attributes:nil error:nil];
    }
    return self;
}

- (NSString *)cachesPath {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"EGF2Images"];
}

- (void)imageWithFile:(EGFFile *)file completion:(void (^) (UIImage *image, BOOL fromCache))completion {
    if (!file || !file.id || !file.url) {
        completion(nil, false);
        return;
    }
    NSURL * url = [[NSURL alloc] initWithString:file.url];
    NSURL * localUrl = [NSURL fileURLWithPath:[[self cachesPath] stringByAppendingFormat:@"/%@",file.id]];

    if ([localUrl checkResourceIsReachableAndReturnError:nil]) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            NSData * data = [NSData dataWithContentsOfURL:localUrl];
            UIImage * image = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completion(image, true);
            });
        });
    }
    else {
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.URLCache = nil;
        configuration.HTTPCookieStorage = nil;
        NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration];
        // TODO use [NSURLSession sharedSession] instead
        [[session dataTaskWithURL:url completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
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

- (void)deleteAllFiles {
    [[NSFileManager defaultManager] removeItemAtPath:[self cachesPath] error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:[self cachesPath] withIntermediateDirectories:false attributes:nil error:nil];
}
@end
