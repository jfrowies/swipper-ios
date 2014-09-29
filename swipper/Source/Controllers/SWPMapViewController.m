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
#import "SWPThemeHelper.h"

@interface SWPMapViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *userTrackingButton;
@property (nonatomic, strong, readwrite) NSArray *selectedCategories;

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
    
    //UI appearance
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [SWPThemeHelper colorForNavigationBar];
    
    //SWRevealViewController setup
    SWRevealViewController *revealController = [self revealViewController];
    [self.swipeView addGestureRecognizer:revealController.panGestureRecognizer];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
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
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
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
            self.mapView.userTrackingMode = MKUserTrackingModeFollow;
            break;
        case MKUserTrackingModeFollow:
            self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
            break;
        case MKUserTrackingModeFollowWithHeading:
            self.mapView.userTrackingMode = MKUserTrackingModeNone;
            break;
        default:
            break;
    }
}

#pragma mark - delegate implementation

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    NSString *modeDescription = @"Not following";
    switch (mode) {
        case MKUserTrackingModeFollow:
            modeDescription = @"Following";
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
    //here we have to decide if we need to call the service again to obtain new places
    
    MKMapRect mRect = mapView.visibleMapRect;
    
    //just to avoid fetching a lot of places when the user zooms out too much.
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    double currentDistance = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    if(currentDistance > 50000) return;
    
    //obtaining northWest and southWest points
    MKMapPoint nwMapPoint = MKMapPointMake(mRect.origin.x, mRect.origin.y);
    MKMapPoint seMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMaxY(mRect));
    CLLocationCoordinate2D nwCoord = MKCoordinateForMapPoint(nwMapPoint);
    CLLocationCoordinate2D seCoord = MKCoordinateForMapPoint(seMapPoint);
    
    //calling the service
    __weak SWPMapViewController *weakSelf = self;
    
    [[SWPLoopBackService sharedInstance] fetchPlacesBetweenNorthWest:nwCoord
                                                           southEast:seCoord
                                                             success:^(NSArray *places) {
                                                                 NSLog(@"%d places has been retrieved.", places.count);
                                                                 weakSelf.places = places;
                                                                 
                                                             } failure:^(NSError *error) {
                                                                 
                                                             }];
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
                if([place.placeCategoryId isEqualToString:category.categoryId]) return YES;
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


@end
