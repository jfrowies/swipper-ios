//
//  SWPMapViewController.h
//  swipper
//
//  Created by fernando rowies on 8/26/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>
#import "SWPMenuViewController.h"

@interface SWPMapViewController : UIViewController <MKMapViewDelegate, SWPMenuViewControllerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *swipeView;

@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong, readonly) NSArray *selectedCategories;

@end
