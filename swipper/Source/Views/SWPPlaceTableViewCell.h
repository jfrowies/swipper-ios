//
//  SWPPlaceTableViewCell.h
//  swipper
//
//  Created by Fer Rowies on 10/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPPlaceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *listIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeCityLabel;

@end
