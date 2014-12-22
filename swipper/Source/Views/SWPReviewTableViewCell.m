//
//  SWPReviewTableViewCell.m
//  swipper
//
//  Created by Fer Rowies on 12/21/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPReviewTableViewCell.h"

@interface SWPReviewTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;
@property (weak, nonatomic) IBOutlet UIImageView *star1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star3ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star4ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star5ImageView;
@end

@implementation SWPReviewTableViewCell

- (void)setReview:(NSString *)review {
    _review = review;
    [self.reviewLabel setText:_review];
}

- (void)setStars:(int)stars {
    _stars = stars;
    
    switch (_stars) {
        case 5:
            self.star5ImageView.image = [UIImage imageNamed:@"StarFilled"];
        case 4:
            self.star4ImageView.image = [UIImage imageNamed:@"StarFilled"];
        case 3:
            self.star3ImageView.image = [UIImage imageNamed:@"StarFilled"];
        case 2:
            self.star2ImageView.image = [UIImage imageNamed:@"StarFilled"];
        case 1:
         self.star1ImageView.image = [UIImage imageNamed:@"StarFilled"];
            break;
        default:
            break;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
