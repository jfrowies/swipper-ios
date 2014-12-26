//
//  SWPDetailsViewController.h
//  swipper
//
//  Created by Fernando Rowies on 12/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWPPlace.h"

@interface SWPDetailsViewController : UIViewController

@property (nonatomic, strong) MKUserLocation *userLocation;
@property (strong, nonatomic) id<SWPPlace> place;
@end
