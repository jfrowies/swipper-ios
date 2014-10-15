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
#import "SWRevealViewController.h"
#import "SWPCategory.h"
#import "SWPCategoryStore.h"
#import "SWPThemeHelper.h"
#import <QuartzCore/QuartzCore.h>


@interface SWPMapViewController ()

@property (nonatomic, weak) IBOutlet UIButton *userTrackingButton;
@property (nonatomic, strong, readwrite) NSArray *selectedCategories;
@property (nonatomic) MKMapRect mapRectWithData;

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
    // Do any additional setup after loading the view.
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    //UI appearance
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [SWPThemeHelper colorForNavigationBar];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.userTrackingButton.layer.cornerRadius = 5; // this value vary as per your desire
    self.userTrackingButton.clipsToBounds = YES;
    
    //SWRevealViewController setup
    SWRevealViewController *revealController = [self revealViewController];
    [self.swipeView addGestureRecognizer:revealController.panGestureRecognizer];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MenuIcon"]
                                                                         style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
    [revealButtonItem setTintColor:[UIColor whiteColor]];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    UIViewController *rearNavigationController = [[self revealViewController] rearViewController];
    
    if([rearNavigationController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *menuNavigationController = (UINavigationController *)rearNavigationController;
        UIViewController *rearViewController = menuNavigationController.visibleViewController;
        
        if([rearViewController isKindOfClass:[SWPMenuViewController class]])
        {
            SWPMenuViewController *menuViewController = (SWPMenuViewController *)rearViewController;
            menuViewController.delegate = self;
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

#pragma mark - MKMapView delegate implementation

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    NSString *modeDescription = @"";
    switch (mode) {
        case MKUserTrackingModeNone:
            modeDescription = @"Not following";
            [self.userTrackingButton setImage:[UIImage imageNamed:@"LocateMe"]forState:UIControlStateNormal];
            break;
        case MKUserTrackingModeFollow:
            modeDescription = @"Following";
            [self.userTrackingButton setImage:[UIImage imageNamed:@"LocateMePressed"]forState:UIControlStateNormal];
            break;
        case MKUserTrackingModeFollowWithHeading:
            modeDescription = @"Following with heading";
        default:
            break;
    }
    
    NSLog(@"tracking mode changed to: %@", modeDescription);
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    MKMapRect mRect = mapView.visibleMapRect;
    
    //size in map points of the current region
    double width = MKMapRectGetMaxX(mRect) - mRect.origin.x;
    double height = MKMapRectGetMaxY(mRect) - mRect.origin.y;
    
    //getting map's nw and se corners
    MKMapPoint nwMapCorner = MKMapPointMake(mRect.origin.x, mRect.origin.y);
    MKMapPoint seMapCorner = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMaxY(mRect));
    
    //avoid calling service for extremely large regions
    double currentDistance = MKMetersBetweenMapPoints(nwMapCorner, seMapCorner);
    if(currentDistance > 50000)
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
                                                                 NSLog(@"%d places has been retrieved.", places.count);
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
//    NSString *categoryName0 = [[SWPCategoryStore sharedInstance] categoryNameForId:categoryAnnotation.place.placeCategoryId];
    NSString *categoryName = categoryAnnotation.place.placeCategory;
    UIImage *annotationImage = [UIImage imageNamed:categoryName];
    if (!annotationImage) annotationImage = [UIImage imageNamed:@"DefaultPin"];
    categoryAnnotationView.image = annotationImage;

    return categoryAnnotationView;
}

#pragma mark -

- (void)reloadAnnotations
{
    [self.mapView removeAnnotations: self.mapView.annotations];
    
    NSMutableArray *newAnnotations = [NSMutableArray arrayWithCapacity:self.places.count];
    
    for (id<SWPPlace> place in self.places) {
        
        int index =[self.selectedCategories indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
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

#pragma mark - SWPMenuViewController implementation

- (void)menuViewController:(SWPMenuViewController *)sender userDidSelectCategories:(NSArray *)selectedcategories
{
    self.selectedCategories = selectedcategories;
    [[self revealViewController] setFrontViewPosition:FrontViewPositionLeft animated:YES];
}

#pragma mark - CLLocationManager delegate implementation

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
        self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    }
}


@end
