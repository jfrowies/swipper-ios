//
//  SWPReviewsViewController.h
//  swipper
//
//  Created by Fer Rowies on 12/21/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPReviewsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *reviews;
@end