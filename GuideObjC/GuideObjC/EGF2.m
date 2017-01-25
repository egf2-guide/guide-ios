//
//  EGF2.m
//  EGF2
//
//  Created by EGF2GEN on 09.12.16.
//  Copyright © 2016 EigenGraph. All rights reserved.
//

#import "EGF2.h"

@implementation Graph

+ (EGF2Graph *)shared {
    static EGF2Graph * sharedGraph = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGraph = [[EGF2Graph alloc] initWithName:@"EGF2"];
        sharedGraph.serverURL = [[NSURL alloc] initWithString:@"http://guide.eigengraph.com/v1/"];
        sharedGraph.webSocketURL = [[NSURL alloc] initWithString:@"ws://guide.eigengraph.com:980/v1/listen"];
        sharedGraph.maxPageSize = 50;
        sharedGraph.defaultPageSize = 25;
        sharedGraph.isObjectPaginationMode = false;
        sharedGraph.showLogs = true;
        sharedGraph.idsWithModelTypes = @{
			@"03": EGFUser.self,
			@"06": EGFFile.self,
			@"10": EGFCustomerRole.self,
			@"11": EGFAdminRole.self,
			@"12": EGFPost.self,
			@"13": EGFComment.self
		};
    });
    return sharedGraph;
}
@end

// MARK:- Simple objects
@implementation EGFDimension

-(NSArray*)requiredFields {
	return @[
		@"width",
		@"height"
	];
}
@end

@implementation EGFKeyValue

-(NSArray*)requiredFields {
	return @[
		@"key",
		@"value"
	];
}
@end

@implementation EGFHumanName

-(NSArray*)requiredFields {
	return @[
		@"use",
		@"given",
		@"prefix",
		@"suffix",
		@"middle",
		@"family"
	];
}
@end

@implementation EGFResize

-(NSArray*)requiredFields {
	return @[
		@"url",
		@"dimensions"
	];
}
@end

@implementation EGFTime

-(NSArray*)requiredFields {
	return @[
		@"minute",
		@"second",
		@"hour"
	];
}
@end

@implementation EGFEdge

-(NSArray*)requiredFields {
	return @[
		@"src",
		@"name",
		@"dst"
	];
}
@end

@implementation EGFDate

-(NSArray*)requiredFields {
	return @[
		@"dayOfWeek",
		@"year",
		@"month",
		@"day"
	];
}
@end

// MARK:- Base graph object
@implementation EGFGraphObject

-(NSArray*)editableFields {
	return @[];
}

-(NSArray*)requiredFields {
	return @[
		@"modifiedAt",
		@"id",
		@"createdAt"
	];
}
@end

// MARK:- Common objects
@implementation EGFPost

-(NSArray*)editableFields {
	return [[super editableFields] arrayByAddingObjectsFromArray: @[
		@"desc"
	]];
}

-(NSArray*)requiredFields {
	return [[super requiredFields] arrayByAddingObjectsFromArray: @[
		@"creator",
		@"image",
		@"desc"
	]];
}
@end

@implementation EGFFile

-(NSDictionary*)listPropertiesInfo {
	return @{
		@"resizes": EGFResize.self
	};
}

-(NSArray*)editableFields {
	return [[super editableFields] arrayByAddingObjectsFromArray: @[
		@"title",
		@"mimeType"
	]];
}

-(NSArray*)requiredFields {
	return [[super requiredFields] arrayByAddingObjectsFromArray: @[
		@"url",
		@"mimeType",
		@"user"
	]];
}
@end

@implementation EGFCustomerRole


-(NSArray*)requiredFields {
	return [[super requiredFields] arrayByAddingObjectsFromArray: @[
		@"user"
	]];
}
@end

@implementation EGFComment

-(NSArray*)editableFields {
	return [[super editableFields] arrayByAddingObjectsFromArray: @[
		@"text"
	]];
}

-(NSArray*)requiredFields {
	return [[super requiredFields] arrayByAddingObjectsFromArray: @[
		@"creator",
		@"post",
		@"text"
	]];
}
@end

@implementation EGFAdminRole


-(NSArray*)requiredFields {
	return [[super requiredFields] arrayByAddingObjectsFromArray: @[
		@"user"
	]];
}
@end

@implementation EGFUser

-(NSArray*)editableFields {
	return [[super editableFields] arrayByAddingObjectsFromArray: @[
		@"name"
	]];
}

-(NSArray*)requiredFields {
	return [[super requiredFields] arrayByAddingObjectsFromArray: @[
		@"email",
		@"system",
		@"name"
	]];
}
@end

