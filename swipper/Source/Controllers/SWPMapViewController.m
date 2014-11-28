//
//  SWPMapViewController.m
//  swipper
//
//  Created by fernando rowies on 8/26/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPMapViewController.h"
#import "SWPLoopBackService.h"
#import "LBPlace.h"
#import "SWPAnnotation.h"
#import "SWPCategory.h"
#import "SWPCategoryStore.h"
#import "SWPThemeHelper.h"
#import "SWPSlidingMenuViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kMaxAllowedDistanceBetweenMapCorners 50000

@interface SWPMapViewController ()

@property (nonatomic, weak) IBOutlet UIButton *userTrackingButton;
@property (nonatomic, strong, readwrite) NSArray *selectedCategories;
@property (nonatomic) MKMapRect mapRectWithData;
@property (nonatomic, strong) SWPSlidingMenuViewController *slidingMenu;
@property (nonatomic) bool locationServicesAlreadyAuthorized;

@end

@implementation SWPMapViewController

#pragma mark - getters/setters

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    [self reloadAnnotations];
}

- (void)setSelectedCategories:(NSArray *)selectedCategories
{
    _selectedCategories = selectedCategories;
    [self reloadAnnotations];
}

#define MapViewLocationServicesAlreadyAuthorizedKey @"mapViewLocationServicesAlreadyAuthorizedKey"

- (void)setLocationServicesAlreadyAuthorized:(bool)firstTimeAuthorized {
    [[NSUserDefaults standardUserDefaults] setInteger:firstTimeAuthorized forKey:MapViewLocationServicesAlreadyAuthorizedKey];
}

- (bool)locationServicesAlreadyAuthorized {
    return [[NSUserDefaults standardUserDefaults] integerForKey:MapViewLocationServicesAlreadyAuthorizedKey]
       ;
}
#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //setting up location manager
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.mapView.showsUserLocation = YES;
    [self.mapView setRegion:[self loadStoredUserRegion] animated:NO];
    self.mapView.userTrackingMode = [self loadStoredUserTrackingMode];
    [self setLocateMeButtonImageForTrackingMode:self.mapView.userTrackingMode];
    
    //UI appearance
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [SWPThemeHelper colorForNavigationBar];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    //User tracking button UI adjustments
    self.userTrackingButton.layer.cornerRadius = 5;
    self.userTrackingButton.clipsToBounds = YES;
    
    self.slidingMenu = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SlidingMenuViewController"];
    
    self.selectedCategories = [[SWPCategoryStore sharedInstance] selectedCategories];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - target action

- (IBAction)userTrackingButtonTouched:(UIButton *)sender {

    switch (self.mapView.userTrackingMode) {
        case MKUserTrackingModeNone:
            [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
            break;
        case MKUserTrackingModeFollow:
            [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
            break;
        case MKUserTrackingModeFollowWithHeading:
            [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
            break;
        default:
            break;
    }
}

- (IBAction)showMenu
{
    if(!self.slidingMenu.isBeingPresented) {
        [self.slidingMenu presentSlidingMenuInViewController:self andView:self.view];
        self.slidingMenu.delegate = self;
    }else {
        self.slidingMenu.delegate = nil;
        [self.slidingMenu hide];
    }
}

#pragma mark - MKMapView delegate implementation

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    [self storeUserTrackingMode:mode];
    [self setLocateMeButtonImageForTrackingMode:mode];
}

- (void)setLocateMeButtonImageForTrackingMode:(MKUserTrackingMode)mode {
    switch (mode) {
        case MKUserTrackingModeNone:
            [self.userTrackingButton setImage:[UIImage imageNamed:@"LocateMe"]forState:UIControlStateNormal];
            break;
        case MKUserTrackingModeFollow:
            [self.userTrackingButton setImage:[UIImage imageNamed:@"LocateMePressed"]forState:UIControlStateNormal];
            break;
        case MKUserTrackingModeFollowWithHeading:
        default:
            break;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    [self storeUserRegion:self.mapView.region];
    
    MKMapRect mRect = mapView.visibleMapRect;
    
    //size in map points of the current region
    double width = MKMapRectGetMaxX(mRect) - mRect.origin.x;
    double height = MKMapRectGetMaxY(mRect) - mRect.origin.y;
    
    //getting map's nw and se corners
    MKMapPoint nwMapCorner = MKMapPointMake(mRect.origin.x, mRect.origin.y);
    MKMapPoint seMapCorner = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMaxY(mRect));
    
    //avoid calling service for extremely large regions
    double currentDistance = MKMetersBetweenMapPoints(nwMapCorner, seMapCorner);
    if(currentDistance > kMaxAllowedDistanceBetweenMapCorners)
        return;
    
    //avoid calling service for non significative scrolls
    if(MKMapRectContainsRect(self.mapRectWithData, mRect))
        return;
    
    
    //getting nw and sw points, the result is bigger than the current map region to avoid recurrent service calls.
    MKMapPoint nwMapPoint = MKMapPointMake(mRect.origin.x - width, mRect.origin.y - height);
    MKMapPoint seMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect) + width, MKMapRectGetMaxY(mRect) + width);
    
    //the region in which we will have annotations
    MKMapRect mapRectToFill = MKMapRectMake(nwMapPoint.x, nwMapPoint.y, seMapPoint.x - nwMapPoint.x, seMapPoint.y - nwMapPoint.x);

    CLLocationCoordinate2D nwCoord = MKCoordinateForMapPoint(nwMapPoint);
    CLLocationCoordinate2D seCoord = MKCoordinateForMapPoint(seMapPoint);
    

    //calling the service
    __weak SWPMapViewController *weakSelf = self;
    
    [[SWPLoopBackService sharedInstance] fetchPlacesBetweenNorthWest:nwCoord
                                                           southEast:seCoord
                                                             success:^(NSArray *places) {
                                                                 weakSelf.places = places;
                                                                 weakSelf.mapRectWithData = mapRectToFill;
                                                             } failure:^(NSError *error) {
                                                                 
                                                             }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
     if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView *categoryAnnotationView = nil;

    static NSString *categoryPinID = @"categoryPin";
    categoryAnnotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:categoryPinID];
    if ( categoryAnnotationView == nil ) categoryAnnotationView = [[MKAnnotationView alloc]
                                         initWithAnnotation:annotation reuseIdentifier:categoryPinID];
        
    categoryAnnotationView.canShowCallout = YES;
        
    SWPAnnotation *categoryAnnotation = (SWPAnnotation *)annotation;
//    NSString *categoryName = [[SWPCategoryStore sharedInstance] categoryNameForId:categoryAnnotation.place.placeCategoryId];
    NSString *categoryName = categoryAnnotation.place.placeCategory;
    UIImage *annotationImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@PinImage",categoryName]];
    if (!annotationImage) annotationImage = [UIImage imageNamed:@"DefaultPinImage"];
    categoryAnnotationView.image = annotationImage;

    return categoryAnnotationView;
}

#pragma mark -

- (void)reloadAnnotations
{
    [self.mapView removeAnnotations: self.mapView.annotations];
    
    NSMutableArray *newAnnotations = [NSMutableArray arrayWithCapacity:self.places.count];
    
    for (id<SWPPlace> place in self.places) {
        
        NSUInteger index =[self.selectedCategories indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj conformsToProtocol:@protocol(SWPCategory)])
            {
                id<SWPCategory> category = (id<SWPCategory>) obj;
                if([place.placeCategory isEqualToString:category.categoryName]) return YES;
            }
            return NO;
        }];
        
        if(index != NSNotFound)
        {
            [newAnnotations addObject: [[SWPAnnotation alloc] initWithPlace:place]];
        }
    }
    
    [self.mapView addAnnotations:[newAnnotations copy]];
}

#pragma mark - SWPSlidingMenuViewControllerDelegate implementation

- (void)slidingMenuViewController:(SWPSlidingMenuViewController *)sender userDidSelectCategories:(NSArray *)selectedCategories
{
    self.selectedCategories = selectedCategories;
    [self.slidingMenu hide];
}

#pragma mark - CLLocationManager delegate implementation

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if(!self.locationServicesAlreadyAuthorized){
            self.mapView.showsUserLocation = YES;
            self.mapView.userTrackingMode = MKUserTrackingModeFollow;
            self.locationServicesAlreadyAuthorized = YES;
        }
    }
}

#pragma mark - Map User Settings

#define MapViewRegionCenterLatitudeKey @"mapViewRegionCenterLatitudeKey"
#define MapViewRegionCenterLongitudeKey @"mapViewRegionCenterLongitudeKey"
#define MapViewRegionSpanLatitudeDeltaKey @"mapViewRegionSpanLatitudeDeltaKey"
#define MapViewRegionSpanLongitudeDeltaKey @"mapViewRegionSpanLongitudeDeltaKey"

- (void)storeUserRegion:(MKCoordinateRegion)region {
    
    [[NSUserDefaults standardUserDefaults] setFloat:region.center.latitude forKey:MapViewRegionCenterLatitudeKey];
    [[NSUserDefaults standardUserDefaults] setFloat:region.center.longitude forKey:MapViewRegionCenterLongitudeKey];
    [[NSUserDefaults standardUserDefaults] setFloat:region.span.latitudeDelta forKey:MapViewRegionSpanLatitudeDeltaKey];
    [[NSUserDefaults standardUserDefaults] setFloat:region.span.longitudeDelta forKey:MapViewRegionSpanLongitudeDeltaKey];
}

- (MKCoordinateRegion)loadStoredUserRegion {
    
    MKCoordinateRegion storedRegion;
    
    storedRegion.center.latitude = [[NSUserDefaults standardUserDefaults] floatForKey:MapViewRegionCenterLatitudeKey];
    storedRegion.center.longitude = [[NSUserDefaults standardUserDefaults] floatForKey:MapViewRegionCenterLongitudeKey];
    storedRegion.span.latitudeDelta = [[NSUserDefaults standardUserDefaults] floatForKey:MapViewRegionSpanLatitudeDeltaKey];
    storedRegion.span.longitudeDelta = [[NSUserDefaults standardUserDefaults] floatForKey:MapViewRegionSpanLongitudeDeltaKey];
    
    return storedRegion;
}

#define MapViewUserTrackingModeKey @"mapViewUserTrackingModeKey"

- (void)storeUserTrackingMode:(MKUserTrackingMode)trackingMode {
    
    [[NSUserDefaults standardUserDefaults] setInteger:trackingMode forKey:MapViewUserTrackingModeKey];
}

- (MKUserTrackingMode)loadStoredUserTrackingMode {
    
    MKUserTrackingMode storedMode = [[NSUserDefaults standardUserDefaults] integerForKey:MapViewUserTrackingModeKey];
    return storedMode;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //assigning places from map to the list for testing propouses
    if([segue.destinationViewController isKindOfClass:[UINavigationController class]]){
        UINavigationController *destinationNavigationController= segue.destinationViewController;
        if([destinationNavigationController.viewControllers.firstObject respondsToSelector:@selector(setPlaces:)]){
            [destinationNavigationController.viewControllers.firstObject performSelector:@selector(setPlaces:) withObject:self.places];
        }
        if([destinationNavigationController.viewControllers.firstObject respondsToSelector:@selector(setUserLocation:)]){
            [destinationNavigationController.viewControllers.firstObject performSelector:@selector(setUserLocation:) withObject:self.mapView.userLocation];
        }
    }
}

@end
