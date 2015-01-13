//
//  SWPReviewsViewController.m
//  swipper
//
//  Created by Fer Rowies on 12/21/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPReviewsViewController.h"
#import "SWPReviewTableViewCell.h"
#import "SWPReview.h"
#import "SWPRestService.h"

@interface SWPReviewsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@end

@implementation SWPReviewsViewController

#pragma mark - Getters/Setters

- (void)setReviews:(NSArray *)reviews {
    _reviews = reviews;
    if(reviews.count>0) {
        self.infoView.hidden = YES;
    }else {
        self.infoView.hidden = NO;
    }
    [self.tableView reloadData];
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.contentInset = UIEdgeInsetsMake(75, 0, 100, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UITableViewControllerDataSource>


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reviews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SWPReviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell" forIndexPath:indexPath];
    
    SWPReview *review = [self.reviews objectAtIndex:indexPath.row];
    
    cell.review = review.placeReview;
    cell.stars = review.placeStars;
    
    return cell;
}

#pragma mark - <UITableViewControllerDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    double labelHeight = 0;
    double imageHeight = 15;
    double insetsHeight = 10;
    
    SWPReview *review = [self.reviews objectAtIndex:indexPath.row];
     
    CGSize constrainedSize = CGSizeMake(self.view.frame.size.width, 9999);
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"HelveticaNeue" size:15.0], NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:review.placeReview attributes:attributesDictionary];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];

    labelHeight = requiredHeight.size.height;
    
    return labelHeight+imageHeight+insetsHeight;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 100, 15)];
//    [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
//    [label setText:@"REVIEWS"];
//    return label;
//}

@end
