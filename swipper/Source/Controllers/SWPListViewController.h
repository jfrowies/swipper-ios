//
//  SWPListViewController.h
//  swipper
//
//  Created by Fer Rowies on 10/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>
#import "SWPSlidingMenuViewController.h"
#import "SWPMessageBarViewController.h"

@class SWPListViewController;

@protocol SWPListViewControllerDelegate <NSObject>

- (void)didDismissListViewController:(SWPListViewController *)listViewController;

@end

@interface SWPListViewController : SWPMessageBarViewController <UITableViewDelegate, UITableViewDataSource,SWPSlidingMenuViewControllerDelegate>

@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong, readonly) NSArray *selectedCategories;
@property (nonatomic, weak) id<SWPListViewControllerDelegate> delegate;

@end
