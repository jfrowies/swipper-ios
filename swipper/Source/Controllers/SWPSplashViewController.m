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
#import "SWRevealViewController.h"

@interface SWPSplashViewController ()

@end

@implementation SWPSplashViewController

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
    // Do any additional setup after loading the view.
    self.splashImageView.image = [UIImage imageNamed:@"splash.png"];
    
    //calling the service
    __weak SWPSplashViewController *weakSelf = self;
    
    [[SWPLoopBackService sharedInstance] fetchAllCategoriesSuccess:^(NSArray *categories) {
        [[SWPCategoryStore sharedInstance] setPlacesCategories:categories];
        [[SWPCategoryStore sharedInstance] setSelectedCategories:categories];
        [weakSelf performSegueWithIdentifier:@"startApplicationSegue" sender:weakSelf];
    } failure:^(NSError *error) {
        NSLog(@"Failed fetching categories");
        [weakSelf performSegueWithIdentifier:@"startApplicationSegue" sender:weakSelf];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //we don't need to set anything on dvc, at least for now.
}


@end
