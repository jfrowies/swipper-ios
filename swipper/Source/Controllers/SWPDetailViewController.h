//
//  SWPDetailViewController.h
//  swipper
//
//  Created by Fer Rowies on 11/26/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWPPlace.h"

@interface SWPDetailViewController : UIViewController

@property (nonatomic, strong) id<SWPPlace> place;

@end
