//
//  SWPLoadingViewController.h
//  swipper
//
//  Created by Fer Rowies on 11/29/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPLoadingViewController : UIViewController

@property (copy, nonatomic) NSString *message;
@property (nonatomic) BOOL showSpinner;
@property (nonatomic) BOOL isBeingPresented;

- (void)presentLoadingViewControllerInViewController:(UIViewController *)viewController
                                             andView:(UIView *)view
                                            animated:(BOOL)animated;
- (void)hideLoadingViewControllerAnimated:(BOOL)animated;

@end
