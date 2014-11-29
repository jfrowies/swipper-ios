//
//  SWPPlaceTableViewCell.m
//  swipper
//
//  Created by Fer Rowies on 10/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPPlaceTableViewCell.h"
#import "SWPThemeHelper.h"

@interface SWPPlaceTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeCityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *listIconImageView;
@end

@implementation SWPPlaceTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPlace:(id<SWPPlace>)place {
    _place = place;
    
    self.placeNameLabel.text = place.placeName;
    self.placeAddressLabel.text = place.placeAddress;
    self.placeCityLabel.text = [NSString stringWithFormat:@"%@, %@, %@",place.placeCity,place.placeState,place.placeCountry];
    self.listIconImageView.backgroundColor = [SWPThemeHelper colorForCategoryName:place.placeCategory];
    self.listIconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@CellImage",place.placeCategory]];
}

@end
