//
//  SWPMenuViewController.h
//  swipper
//
//  Created by fernando rowies on 9/10/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWPMenuViewController;

@protocol SWPMenuViewControllerDelegate <NSObject>

- (void)menuViewController:(SWPMenuViewController *)sender userDidSelectCategories:(NSArray *)selectedcategories;

@end

@interface SWPMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *placesCategories;
@property (nonatomic, weak) id<SWPMenuViewControllerDelegate> delegate;
@end
