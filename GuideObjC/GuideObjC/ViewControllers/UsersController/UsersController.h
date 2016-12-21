//
//  UsersController.h
//  GuideObjC
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

#import "BaseTableViewController.h"
#import "SearchingHandler.h"
#import "UserCell.h"

@interface UsersController : BaseTableViewController <SearchingHandlerDelegate, UserCellDelegate>

@end
