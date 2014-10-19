//
//  SWPListViewController.h
//  swipper
//
//  Created by Fer Rowies on 10/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWPMenuViewController.h"

@interface SWPListViewController : UITableViewController <SWPMenuViewControllerDelegate>

@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong, readonly) NSArray *selectedCategories;

@end
