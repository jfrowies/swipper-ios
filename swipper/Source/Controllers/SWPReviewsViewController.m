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
#import "SWPSimpleReview.h"

@interface SWPReviewsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SWPReviewsViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray *fakeReviews = [NSMutableArray arrayWithCapacity:6];
    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"El casino del amerian esta bueno." andStars:3]];
    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Este casino es la peor porqueria que vi en mi vida." andStars:1]];
    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Zafa." andStars:2]];
    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Es muuuy caro." andStars:1]];
    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Baratito baratito." andStars:5]];
    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Un hotel muy lindo, me sorprendio." andStars:5]];
    self.reviews = [fakeReviews copy];
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
    
    id<SWPReview> review = [self.reviews objectAtIndex:indexPath.row];
    
    cell.review = review.placeReview;
    cell.stars = review.placeStars;
    
    return cell;
}

#pragma mark - <UITableViewControllerDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    double labelHeight = 0;
    double imageHeight = 15;
    double insetsHeight = 10;
    
    id<SWPReview> review = [self.reviews objectAtIndex:indexPath.row];
    
    
//    labelHeight = [review.placeReview boundingRectWithSize:CGSizeMake(15, MAXFLOAT)
//                                          options:NSStringDrawingUsesLineFragmentOrigin
//                                       attributes:@{
//                                                    NSFontAttributeName : @"helvetica neue"
//                                                    }
//                                          context:nil].size.height;
    
    CGSize constrainedSize = CGSizeMake(250, 9999);
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"HelveticaNeue" size:15.0], NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:review.placeReview attributes:attributesDictionary];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];

    labelHeight = requiredHeight.size.height;
    
    return labelHeight+imageHeight+insetsHeight;
}

@end
