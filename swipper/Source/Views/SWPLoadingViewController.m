//
//  SWPLoadingViewController.m
//  swipper
//
//  Created by Fer Rowies on 11/29/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPLoadingViewController.h"

@interface SWPLoadingViewController ()
@property (weak, nonatomic) IBOutlet UIView *spinnerBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelYConstraint;
@property (nonatomic) BOOL animateShow;
@property (nonatomic) BOOL animateHide;
@end

@implementation SWPLoadingViewController

#define labelYConstantSpinnerVisible -30.0f
#define labelYConstantSpinnerHide 0.0f

#pragma mark - Getters/Setters

- (void)setMessage:(NSString *)message {
    _message = message;
    [self.messageLabel setText:_message];
}

- (void)setShowSpinner:(BOOL)showSpinner {
    _showSpinner = showSpinner;
    if(_showSpinner) {
        [self.spinner startAnimating];
        self.labelYConstraint.constant = labelYConstantSpinnerVisible;
    }else {
        [self.spinner stopAnimating];
        self.labelYConstraint.constant = labelYConstantSpinnerHide;
    }
    [self.view layoutIfNeeded];
}

#pragma mark - View Controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.messageLabel setText:self.message];
    if(self.showSpinner) {
        [self.spinner startAnimating];
        self.labelYConstraint.constant = labelYConstantSpinnerVisible;
    }else {
        [self.spinner stopAnimating];
        self.labelYConstraint.constant = labelYConstantSpinnerHide;
    }
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.alpha = 0.0f;
    self.spinnerBackgroundView.layer.cornerRadius = 5;
    self.spinnerBackgroundView.layer.masksToBounds = YES;
}

#define showAnimationDuration 0.2f

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.animateShow) {
        [UIView animateWithDuration:showAnimationDuration animations:^{
            self.view.alpha = 1.0f;
        }];
    }else {
        self.view.alpha = 1.0f;
    }
    self.isBeingPresented = YES;
}


#pragma mark - Presenting/hiding

- (void)presentLoadingViewControllerInViewController:(UIViewController *)viewController
                                             andView:(UIView *)view
                                            animated:(BOOL)animated {
    self.animateShow = animated;
    [viewController addChildViewController:self];
    [view addSubview:self.view];
}

#define hideAnimationDuration 0.2f

- (IBAction)hideLoadingViewControllerAnimated:(BOOL)animated {
    self.animateHide = animated;
    
    if (self.animateHide) {
        [UIView animateWithDuration:hideAnimationDuration animations:^{
            self.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    } else {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
    
    self.isBeingPresented = NO;
}

@end
