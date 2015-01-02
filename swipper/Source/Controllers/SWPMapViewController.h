//
//  SWPMapViewController.h
//  swipper
//
//  Created by fernando rowies on 8/26/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>
#import "SWPSlidingMenuViewController.h"
#import "SWPMessageBarViewController.h"
#import "SWPListViewController.h"

@interface SWPMapViewController : SWPMessageBarViewController <MKMapViewDelegate, SWPSlidingMenuViewControllerDelegate, CLLocationManagerDelegate, SWPListViewControllerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong, readonly) NSArray *selectedCategories;

@end
