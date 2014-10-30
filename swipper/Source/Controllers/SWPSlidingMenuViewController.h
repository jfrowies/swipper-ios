//
//  SWPSlidingMenuViewController.h
//  swipper
//
//  Created by Fer Rowies on 10/29/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWPMenuViewController.h"

@class SWPSlidingMenuViewController;

@protocol SWPSlidingMenuViewControllerDelegate <NSObject>

- (void)slidingMenuViewController:(SWPSlidingMenuViewController *)sender
             userDidSelectCategories:(NSArray *)selectedCategories;

@end

@interface SWPSlidingMenuViewController : UIViewController <SWPMenuViewControllerDelegate>

@property (nonatomic, weak) id<SWPSlidingMenuViewControllerDelegate> delegate;
@property (nonatomic) BOOL isBeingPresented;

- (void)hide;
- (void)presentSlidingMenuInViewController:(UIViewController *)viewController
                                   andView:(UIView *)view;

@end
