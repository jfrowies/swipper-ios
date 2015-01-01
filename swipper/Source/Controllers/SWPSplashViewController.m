//
//  SWPSplashViewController.m
//  swipper
//
//  Created by fernando rowies on 9/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPSplashViewController.h"
#import "SWPCategory.h"
#import "SWPRestService.h"
#import "SWPCategoryStore.h"

@interface SWPSplashViewController ()

@end

@implementation SWPSplashViewController

#pragma mark - View life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.splashImageView.image = [UIImage imageNamed:@"splashswipper.png"];
    self.errrorLabel.hidden = YES;
    self.retrybutton.hidden = YES;
    [self downloadAppData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - App data initialization

- (void)downloadAppData
{
    //in the future we should download some data again
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"startApplicationSegue" sender:self];
    });
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - Actions

- (IBAction)retryButtonTouched:(UIButton *)sender {
    self.errrorLabel.hidden = YES;
    self.retrybutton.hidden = YES;
    [self downloadAppData];
}

@end
