//
//  SWPPlaceTableViewCell.h
//  swipper
//
//  Created by Fer Rowies on 10/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWPPlace.h"

@interface SWPPlaceTableViewCell : UITableViewCell

@property (strong, nonatomic) id<SWPPlace> place;

@end
