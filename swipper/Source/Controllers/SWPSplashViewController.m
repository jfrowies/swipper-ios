//
//  SWPSplashViewController.m
//  swipper
//
//  Created by fernando rowies on 9/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPSplashViewController.h"
#import "SWPCategory.h"
#import "SWPLoopBackService.h"
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
    //in the futuru we should download some data again
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"startApplicationSegue" sender:self];
    });
    
    //now we don't fetch categories from service anymore, that's why this code is commented out.
//    __weak SWPSplashViewController *weakSelf = self;
//    
//    [[SWPLoopBackService sharedInstance] fetchAllCategoriesSuccess:^(NSArray *categories) {
//        [[SWPCategoryStore sharedInstance] setPlacesCategories:categories];
//        [[SWPCategoryStore sharedInstance] setSelectedCategories:categories];
//        [weakSelf performSegueWithIdentifier:@"startApplicationSegue" sender:weakSelf];
//    } failure:^(NSError *error) {
//        NSLog(@"unable to retrieve data from server: %@",error.description);
//        weakSelf.errrorLabel.hidden = NO;
//        weakSelf.retrybutton.hidden = NO;
//    }];
//    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //we don't need to set anything on dvc, at least for now.
}

#pragma mark - Actions

- (IBAction)retryButtonTouched:(UIButton *)sender {
    self.errrorLabel.hidden = YES;
    self.retrybutton.hidden = YES;
    [self downloadAppData];
}



@end
