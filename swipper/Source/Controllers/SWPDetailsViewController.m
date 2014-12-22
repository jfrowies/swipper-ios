//
//  SWPDetailsViewController.m
//  swipper
//
//  Created by Fernando Rowies on 12/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPDetailsViewController.h"
#import <MapKit/MKMapItem.h>
#import "MapKit/MKUserLocation.h"

@interface SWPDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *placeAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *placePhoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeDistanceLabel;
@end

@implementation SWPDetailsViewController

#pragma mark - Getters/Setters


#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = self.place.placeName;
    
    self.navigationController.navigationBar.tintColor= [UIColor whiteColor];
    
    self.placeAddressLabel.text = self.place.placeAddress;
    self.placeCityLabel.text = [NSString stringWithFormat:@"%@, %@, %@",self.place.placeCity,self.place.placeState,self.place.placeCountry];
    self.placePhoneNumberLabel.text = self.place.placePhone;
    
    CLLocation *startLocation = self.userLocation.location;
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:[self.place placeCoordinate].latitude longitude:[self.place placeCoordinate].longitude];
    CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];
    [self.placeDistanceLabel setText:[NSString stringWithFormat:@"%.1f km",distance / 1000]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (IBAction)didTouchedHowToArriveBarButton:(UIBarButtonItem *)sender {
}

- (IBAction)didTouchedPhoneCallBarButton:(UIBarButtonItem *)sender {
}

- (IBAction)didTouchedShareBarButton:(UIBarButtonItem *)sender {
}

- (IBAction)didTouchedSendReportBarButton:(UIBarButtonItem *)sender {
}

@end
