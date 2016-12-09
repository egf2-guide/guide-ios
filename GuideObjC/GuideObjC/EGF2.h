//
//  EGF2.h
//  EGF2
//
//  Created by EGF2GEN on 09.12.16.
//  Copyright © 2016 EigenGraph. All rights reserved.
//

#import <Foundation/Foundation.h>
@import EGF2;

@interface Graph : NSObject
+ (EGF2Graph *)shared;
@end

// MARK:- Simple objects
@interface EGFDimension : NSObject
@property NSInteger width;
@property NSInteger height;
@end

@interface EGFKeyValue : NSObject
@property NSString *key;
@property NSString *value;
@end

@interface EGFHumanName : NSObject
@property NSString *use;
@property NSString *given;
@property NSString *prefix;
@property NSString *suffix;
@property NSString *middle;
@property NSString *family;
@end

@interface EGFResize : NSObject
@property NSString *url;
@property EGFDimension *dimensions;
@end

@interface EGFTime : NSObject
@property NSInteger minute;
@property NSInteger second;
@property NSInteger hour;
@end

@interface EGFEdge : NSObject
@property NSString *src;
@property NSString *name;
@property NSString *dst;
@end

@interface EGFDate : NSObject
@property NSInteger dayOfWeek;
@property NSInteger year;
@property NSInteger month;
@property NSInteger day;
@end

// MARK:- Base graph object
@interface EGFGraphObject: NSObject
@property NSDate *modifiedAt;
@property NSString *id;
@property NSDate *deletedAt;
@property NSDate *createdAt;
-(NSArray*)editableFields;
-(NSArray*)requiredFields;
@end

// MARK:- Common objects
@class EGFFile;
@class EGFUser;
@interface EGFPost : EGFGraphObject
@property NSString *creator;
@property EGFUser *creatorObject;
@property NSString *image;
@property EGFFile *imageObject;
@property NSString *desc;
@end

@class EGFUser;
@interface EGFFile : EGFGraphObject
@property NSString *url;
@property BOOL hosted;
@property BOOL standalone;
@property EGFDimension *dimensions;
@property NSString *uploadUrl;
@property NSString *title;
@property NSInteger size;
@property NSArray <EGFResize *> *resizes;
@property BOOL uploaded;
@property NSString *mimeType;
@property NSString *user;
@property EGFUser *userObject;
@end

@class EGFUser;
@interface EGFCustomerRole : EGFGraphObject
@property NSString *user;
@property EGFUser *userObject;
@end

@class EGFUser;
@interface EGFComment : EGFGraphObject
@property NSString *creator;
@property EGFUser *creatorObject;
@property NSString *post;
@property EGFPost *postObject;
@property NSString *text;
@end

@class EGFUser;
@interface EGFAdminRole : EGFGraphObject
@property NSString *user;
@property EGFUser *userObject;
@end

@interface EGFUser : EGFGraphObject
@property NSString *email;
@property NSString *system;
@property BOOL noPassword;
@property EGFHumanName *name;
@property BOOL verified;
@end

