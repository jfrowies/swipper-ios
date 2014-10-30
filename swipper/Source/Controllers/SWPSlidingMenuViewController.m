//
//  SWPSlidingMenuViewController.m
//  swipper
//
//  Created by Fer Rowies on 10/29/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPSlidingMenuViewController.h"

@interface SWPSlidingMenuViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuLeftConstraint;

@end

@implementation SWPSlidingMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.menuLeftConstraint.constant = -270.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.5f animations:^{
        
        self.menuLeftConstraint.constant = -8.0f;
        
        //        self.view.backgroundColor = [UIColor blackColor];
        //        [self.view setAlpha:0.8f];
        
        [self.view layoutIfNeeded];
    }];
    
    self.isBeingPresented = YES;
}

- (void)presentSlidingMenuInViewController:(UIViewController *)viewController andView:(UIView *)view {
    [viewController addChildViewController:self];
    //[self didMoveToParentViewController:viewController];
    [view addSubview:self.view];
}

- (void)hide {
    [UIView animateWithDuration:0.5f animations:^{
        
        self.menuLeftConstraint.constant = -270.0f;
        
        //        self.view.backgroundColor = [UIColor blackColor];
        //        [self.view setAlpha:0.8f];
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];

    self.isBeingPresented = NO;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
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
