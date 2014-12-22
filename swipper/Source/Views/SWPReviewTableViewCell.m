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
@property (weak, nonatomic) IBOutlet UIImageView *starsImageView;
@end

@implementation SWPReviewTableViewCell

- (void)setReview:(NSString *)review {
    _review = review;
    [self.reviewLabel setText:_review];
}

- (void)setStars:(int)stars {
    _stars = stars;
    
    switch (_stars) {
        case 1:
//            self.starsImageView.image = [UIImage imageNamed:@"TaxiPinImage"];
            self.starsImageView.backgroundColor = [UIColor redColor];
            break;
        case 2:
//            self.starsImageView.image = [UIImage imageNamed:@"LodgingPinImage"];
            self.starsImageView.backgroundColor = [UIColor orangeColor];
            break;
        case 3:
//            self.starsImageView.image = [UIImage imageNamed:@"FoodPinImage"];
            self.starsImageView.backgroundColor = [UIColor yellowColor];
            break;
        case 4:
//            self.starsImageView.image = [UIImage imageNamed:@"GasPinImage"];
            self.starsImageView.backgroundColor = [UIColor greenColor];
            break;
        case 5:
//            self.starsImageView.image = [UIImage imageNamed:@"Car RentalPinImage"];
            self.starsImageView.backgroundColor = [UIColor blueColor];
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
