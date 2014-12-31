//
//  SWPSlidingMenuViewController.m
//  swipper
//
//  Created by Fer Rowies on 10/29/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPSlidingMenuViewController.h"

#define slideAnimationDuration 0.3f
#define hideMenuConstraintConstant -240.0f
#define showMenuConstraintConstant -8.0f

@interface SWPSlidingMenuViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuLeftConstraint;
@property (nonatomic) BOOL animateShow;
@property (nonatomic) BOOL animateHide;
@end

@implementation SWPSlidingMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuLeftConstraint.constant = hideMenuConstraintConstant;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.animateShow) {
        [UIView animateWithDuration:slideAnimationDuration animations:^{
            self.menuLeftConstraint.constant = showMenuConstraintConstant;
            [self.view layoutIfNeeded];
        }];
    } else {
        self.menuLeftConstraint.constant = showMenuConstraintConstant;
        [self.view layoutIfNeeded];
    }
    
    self.isBeingPresented = YES;
    
    if([self.delegate respondsToSelector:@selector(didShowSlidingMenuViewController:)]) {
        [self.delegate didShowSlidingMenuViewController:self];
    }
}

- (void)presentSlidingMenuInViewController:(UIViewController *)viewController andView:(UIView *)view animated:(BOOL)animated {
    self.animateShow = animated;
    [viewController addChildViewController:self];
    [view addSubview:self.view];
}

- (IBAction)hideAnimated:(BOOL)animated {
    self.animateHide = animated;
    
    if (self.animateHide) {
        [UIView animateWithDuration:slideAnimationDuration animations:^{
            self.menuLeftConstraint.constant = hideMenuConstraintConstant;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    } else {
        self.menuLeftConstraint.constant = hideMenuConstraintConstant;
        [self.view layoutIfNeeded];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }

    self.isBeingPresented = NO;
    
    if([self.delegate respondsToSelector:@selector(didHideSlidingMenuViewController:)]) {
        [self.delegate didHideSlidingMenuViewController:self];
    }
}

- (IBAction)didSwipe:(id)sender {
    [self hideAnimated:YES];
}

- (IBAction)didTap:(id)sender {
    [self hideAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"MenuContainerSegue"]) {
        if([segue.destinationViewController isKindOfClass:[SWPMenuViewController class]]) {
            SWPMenuViewController *menu = (SWPMenuViewController *)segue.destinationViewController;
            menu.delegate = self;
        }
    }
}

#pragma mark - SWPMenuViewControllerDelegate implementation

- (void)menuViewController:(SWPMenuViewController *)sender userDidSelectCategories:(NSArray *)selectedcategories
{
    [self.delegate slidingMenuViewController:self userDidSelectCategories:selectedcategories];
}

@end
