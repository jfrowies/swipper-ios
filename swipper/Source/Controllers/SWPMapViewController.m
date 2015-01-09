//
//  SWPMapViewController.m
//  swipper
//
//  Created by fernando rowies on 8/26/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPMapViewController.h"
#import "SWPRestService.h"
#import "LBPlace.h"
#import "SWPAnnotation.h"
#import "SWPCategory.h"
#import "SWPCategoryStore.h"
#import "SWPThemeHelper.h"
#import "SWPSlidingMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SWPListViewController.h"
#import "SWPPlaceAnnotationCalloutView.h"
#import "SWPAnnotationView.h"
#import "SWPDetailsViewController.h"

#define kMaxAllowedDistanceBetweenMapCorners 50000
#define kHideMessageDelay 2.5f

@interface SWPMapViewController ()

@property (nonatomic, weak) IBOutlet UIButton *userTrackingButton;
@property (nonatomic, strong, readwrite) NSArray *selectedCategories;
@property (nonatomic) MKMapRect mapRectWithData;
@property (nonatomic, strong) SWPSlidingMenuViewController *slidingMenu;
@property (nonatomic) BOOL locationServicesAlreadyAuthorized;
@property (nonatomic) BOOL appAlreadyLaunchedBefore;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *listBarButtonItem;
//@property (strong, nonatomic) IBOutlet SWPPlaceAnnotationCalloutView *calloutView;
@property (strong, nonatomic) id<SWPPlace> selectedPlace;

@end

@implementation SWPMapViewController

@synthesize selectedCategories = _selectedCategories;

#pragma mark - Getters/Setters

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    [self reloadAnnotations];
}

- (void)setSelectedCategories:(NSArray *)selectedCategories
{
    _selectedCategories = selectedCategories;
    [[SWPCategoryStore sharedInstance] setSelectedCategories:selectedCategories];
    [self reloadAnnotations];
}

- (NSArray *)selectedCategories
{
    if(!_selectedCategories) {
        _selectedCategories = [[SWPCategoryStore sharedInstance] selectedCategories];
    }
    return _selectedCategories;
}

- (SWPSlidingMenuViewController *)slidingMenu
{
    if(!_slidingMenu) {
        _slidingMenu = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SlidingMenuViewController"];
    }
    return _slidingMenu;
}

#define MapViewLocationServicesAlreadyAuthorizedKey @"mapViewLocationServicesAlreadyAuthorizedKey"

- (void)setLocationServicesAlreadyAuthorized:(BOOL)firstTimeAuthorized
{
    [[NSUserDefaults standardUserDefaults] setInteger:firstTimeAuthorized forKey:MapViewLocationServicesAlreadyAuthorizedKey];
}

- (BOOL)locationServicesAlreadyAuthorized
{
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

#define AppAlreadyLaunchedBeforeKey @"AppAlreadyLaunchedBeforeKey"

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
    
    //Navigation Item title view
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [titleView addSubview:[[UIImageView alloc ] initWithImage:[UIImage imageNamed:@"SwipperLogo"]]];
    titleView.frame = CGRectMake(30, 30, titleView.frame.size.width, titleView.frame.size.height);
    self.navigationItem.titleView = titleView;
    
    //User tracking button UI adjustments
    self.userTrackingButton.layer.cornerRadius = 5;
    self.userTrackingButton.clipsToBounds = YES;
    
    //loading NIB for callout views
//    [[NSBundle mainBundle] loadNibNamed:@"SWPPlaceAnnotationCalloutView" owner:self options:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
     self.appAlreadyLaunchedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:AppAlreadyLaunchedBeforeKey];

    if(!self.appAlreadyLaunchedBefore) {
        [self.slidingMenu presentSlidingMenuInViewController:self andView:self.view animated:NO];
        self.slidingMenu.delegate = self;

        //TODO: show onboarding screen
    }
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
        [self.slidingMenu presentSlidingMenuInViewController:self andView:self.view animated:YES];
        self.slidingMenu.delegate = self;
    }else {
        [self.slidingMenu hideAnimated:YES];
    }
}

#pragma mark - MKMapView delegate implementation

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    [self storeUserTrackingMode:mode];
    [self setLocateMeButtonImageForTrackingMode:mode];
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
    if(currentDistance > kMaxAllowedDistanceBetweenMapCorners) {
        [self showMessage:@"zoom in to load places" withBarType:MessageBarInfo animated:YES];
        [self hideMessageAfterDelay:kHideMessageDelay Animated:YES];
        return;
    }

    
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

    [self showMessage:@"loading places" withBarType:MessageBarInfo animated:YES];
    
    //calling the service
    __weak SWPMapViewController *weakSelf = self;
    
    [[SWPRestService sharedInstance] fetchPlacesBetweenNorthWest:nwCoord
                                                           southEast:seCoord
                                                             success:^(NSArray *places) {
                                                                weakSelf.places = places;
                                                                weakSelf.mapRectWithData = mapRectToFill;
                                                                
                                                                 if (places.count>1){
                                                                     [weakSelf showMessage:@"done" withBarType:MessageBarInfo animated:NO];
                                                                 }else {
                                                                     [weakSelf showMessage:@"no places found, try changing location" withBarType:MessageBarInfo animated:NO];

                                                                 }
                                                                 [weakSelf hideMessageAfterDelay:kHideMessageDelay Animated:YES];
                                                                 
                                                             } failure:^(NSError *error) {
                                                                 [weakSelf showMessage:@"error loading places" withBarType:MessageBarError animated:NO];
                                                                  [weakSelf hideMessageAfterDelay:kHideMessageDelay Animated:YES];
                                                             }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
     if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    SWPAnnotationView *categoryAnnotationView = nil;

    static NSString *categoryPinID = @"categoryPin";
    categoryAnnotationView = (SWPAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:categoryPinID];
    if ( categoryAnnotationView == nil ) categoryAnnotationView = [[SWPAnnotationView alloc]
                                         initWithAnnotation:annotation reuseIdentifier:categoryPinID];
        
    categoryAnnotationView.canShowCallout = YES;
        
    SWPAnnotation *categoryAnnotation = (SWPAnnotation *)annotation;
    NSString *categoryName = categoryAnnotation.place.placeCategory;
    UIImage *annotationImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@PinImage",categoryName]];
    if (!annotationImage) annotationImage = [UIImage imageNamed:@"DefaultPinImage"];
    categoryAnnotationView.image = annotationImage;
    
//    categoryAnnotationView.calloutView = self.calloutView;
    UIButton *rightView =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [rightView setImage:[UIImage imageNamed:@"ArrowYellow"] forState:UIControlStateNormal];
    categoryAnnotationView.rightCalloutAccessoryView = rightView;
    return categoryAnnotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if([view.annotation isKindOfClass:[SWPAnnotation class]]) {
        self.selectedPlace = ((SWPAnnotation *)view.annotation).place;
        [self performSegueWithIdentifier:@"showDetailsFromMap" sender:self];
    }
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
            SWPAnnotation *annot = [[SWPAnnotation alloc] initWithPlace:place];
            annot.userLocation = self.mapView.userLocation;
            
            [newAnnotations addObject: annot];
        }
    }
    
    if(newAnnotations.count == 0) {
        [self showMessage:@"no places found, try changing filters" withBarType:MessageBarInfo animated:YES];
        [self hideMessageAfterDelay:kHideMessageDelay Animated:YES];
    }
    
    [self.mapView addAnnotations:[newAnnotations copy]];
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

#pragma mark - SWPSlidingMenuViewControllerDelegate implementation

- (void)slidingMenuViewController:(SWPSlidingMenuViewController *)sender userDidSelectCategories:(NSArray *)selectedCategories
{
    if(!self.appAlreadyLaunchedBefore) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AppAlreadyLaunchedBeforeKey];
    }
    self.selectedCategories = selectedCategories;
    [self.slidingMenu hideAnimated:YES];
}

- (void)didShowSlidingMenuViewController:(SWPSlidingMenuViewController *)sender {
    self.listBarButtonItem.enabled = NO;
    [UIView animateWithDuration:0.2f animations:^{
        self.mapView.alpha = 0.5f;
        self.userTrackingButton.alpha = 0.5f;
    }];
}

- (void)didHideSlidingMenuViewController:(SWPSlidingMenuViewController *)sender {
    self.listBarButtonItem.enabled = YES;
    [UIView animateWithDuration:0.2f animations:^{
        self.mapView.alpha = 1;
        self.userTrackingButton.alpha = 1;
    }];
}

#pragma mark - CLLocationManager delegate implementation

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if(!self.locationServicesAlreadyAuthorized){
            self.mapView.showsUserLocation = YES;
            self.mapView.userTrackingMode = MKUserTrackingModeFollow;
            self.locationServicesAlreadyAuthorized = YES;
        }
    }else if (status == kCLAuthorizationStatusDenied){
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Location services disabled"
                                              message:@"Please, go to Settings > Privacy > Location and enable location services for Swipper."
                                              preferredStyle:UIAlertControllerStyleAlert];

        
        UIAlertAction *settingsAction = [UIAlertAction
                                   actionWithTitle:@"Settings"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
                                   }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                         actionWithTitle:@"Cancel"
                                         style:UIAlertActionStyleDefault
                                         handler:nil];
        
        [alertController addAction:settingsAction];
        [alertController addAction:cancelAction];

        [self presentViewController:alertController animated:YES completion:nil];

    }
}

#pragma mark - SWPListViewController delegate implementation

- (void)didDismissListViewController:(SWPListViewController *)listViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.selectedCategories = [[SWPCategoryStore sharedInstance] selectedCategories];
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
    
    if([segue.identifier isEqualToString:@"showListNavigationController"]) {
        UINavigationController *destinationNavigationController= segue.destinationViewController;
        if([destinationNavigationController.viewControllers.firstObject isKindOfClass:[SWPListViewController class]]) {
            SWPListViewController *listViewController = destinationNavigationController.viewControllers.firstObject;
            listViewController.userLocation = self.mapView.userLocation;
            listViewController.places = self.places;
            listViewController.delegate = self;
        }
    }
    
    if([segue.identifier isEqualToString:@"showDetailsFromMap"]) {
        UIViewController *dvc= segue.destinationViewController;
        if([dvc isKindOfClass:[SWPDetailsViewController class]]) {
            SWPDetailsViewController *detailsViewController = (SWPDetailsViewController *)dvc;
            detailsViewController.userLocation = self.mapView.userLocation;
            detailsViewController.place = self.selectedPlace;
        }
    }
}

@end
