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
#import "SWPLoopBackService.h"

@interface SWPReviewsViewController ()
@property (strong, nonatomic) NSArray *reviews;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SWPReviewsViewController

#pragma mark - Getters/Setters

- (void)setPlace:(id<SWPPlace>)place {
    _place = place;
    [self loadPlaceReviews];
}

- (void)setReviews:(NSArray *)reviews {
    _reviews = reviews;
    [self.tableView reloadData];
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSMutableArray *fakeReviews = [NSMutableArray arrayWithCapacity:6];
//    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"El casino del amerian esta bueno." andStars:3]];
//    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Este casino es la peor porqueria que vi en mi vida." andStars:1]];
//    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Zafa." andStars:2]];
//    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Es muuuy caro." andStars:0]];
//    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Baratito baratito." andStars:5]];
//    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Un hotel muy lindo, me sorprendio." andStars:5]];
//    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"El casino del amerian esta bueno." andStars:3]];
//    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Este casino es la peor porqueria que vi en mi vida." andStars:1]];
//    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Zafa." andStars:2]];
//    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Es muuuy caro." andStars:0]];
//    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Baratito baratito." andStars:5]];
//    [fakeReviews addObject:[SWPSimpleReview reviewWithText:@"Un hotel muy lindo, me sorprendio." andStars:5]];
//    
//    self.reviews = [fakeReviews copy];
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

- (void)loadPlaceReviews {
//    [[SWPLoopBackService sharedInstance] fetchPlaceReviewsWithPlaceId:self.place.placeId success:^(NSArray *reviews) {
//        self.reviews = reviews;
//    } failure:^(NSError *error) {
//        //TODO: show error
//    }];
}

@end
