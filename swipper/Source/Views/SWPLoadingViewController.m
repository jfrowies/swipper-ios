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
@end

@implementation SWPLoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.2f animations:^{
        self.view.alpha = 1.0f;
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
