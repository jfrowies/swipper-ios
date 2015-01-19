//
//  SWPReviewsViewController.h
//  swipper
//
//  Created by Fer Rowies on 12/21/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWPReviewsViewController;

@protocol SWPReviewsViewControllerDelegate <NSObject>
@optional
- (CGFloat)reviewsViewController:(SWPReviewsViewController *)reviewsViewController topInsetForViewWidth:(CGFloat)width;
- (CGFloat)reviewsViewController:(SWPReviewsViewController *)reviewsViewController bottomInsetForViewWidth:(CGFloat)width;
@end

@interface SWPReviewsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *reviews;
@property (weak, nonatomic) id<SWPReviewsViewControllerDelegate> delegate;
@end
