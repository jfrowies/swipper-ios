//
//  SWPDetailViewController.m
//  swipper
//
//  Created by Fer Rowies on 11/26/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPDetailViewController.h"

@interface SWPDetailViewController ()

@property (nonatomic, weak) IBOutlet UILabel *placeName;

@end

@implementation SWPDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.placeName setText:[self.place placeName]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
