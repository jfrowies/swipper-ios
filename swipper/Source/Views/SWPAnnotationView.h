//
//  SWPAnnotationView.h
//  swipper
//
//  Created by Fernando Rowies on 12/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface SWPAnnotationView : MKAnnotationView
@property (weak, nonatomic) UIView *calloutView;
@end
