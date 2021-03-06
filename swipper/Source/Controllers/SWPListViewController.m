//
//  SWPListViewController.m
//  swipper
//
//  Created by Fer Rowies on 10/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPListViewController.h"
#import "SWPThemeHelper.h"
#import "SWPPlace.h"
#import "SWPPlaceTableViewCell.h"
#import "SWPCategoryStore.h"
#import <MapKit/MKMapItem.h>
#import "MapKit/MKUserLocation.h"
#import "SWPLoadingViewController.h"
#import "SWPDetailsViewController.h"
#import "JSNetworkActivityIndicatorManager.h"

@interface SWPListViewController ()

@property (strong, nonatomic, readwrite) NSArray *selectedCategories;
@property (strong, nonatomic) SWPSlidingMenuViewController *slidingMenu;
@property (strong, nonatomic) NSArray *placesToShow;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;
@property (strong, nonatomic) SWPLoadingViewController *loadingViewController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) id<SWPPlace> selectedPlace;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@end

@implementation SWPListViewController

#pragma mark - Getters/Setters

@synthesize selectedCategories = _selectedCategories;

- (void)setPlaces:(NSArray *)places
{
    //ordering places by distance to user location
    NSArray *orderedPlaces = [places sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      
        CLLocation *startLocation = self.userLocation.location;
        CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:[obj1 placeCoordinate].latitude longitude:[obj1 placeCoordinate].longitude];
        CLLocationDistance distance1 = [startLocation distanceFromLocation:endLocation];

        endLocation = [[CLLocation alloc] initWithLatitude:[obj2 placeCoordinate].latitude longitude:[obj2 placeCoordinate].longitude];
        CLLocationDistance distance2 = [startLocation distanceFromLocation:endLocation];
        
        if (distance1 < distance2) {
            return NSOrderedAscending;
        } else if (distance1 > distance2) {
            return NSOrderedDescending;
        }else {
          return NSOrderedSame;
        }
        
    }];
    
    _places = orderedPlaces;
    self.placesToShow = [self filterPlaces:_places usingCategories:self.selectedCategories];
}

- (void)setSelectedCategories:(NSArray *)selectedCategories
{
    _selectedCategories = selectedCategories;
    [[SWPCategoryStore sharedInstance] setSelectedCategories:selectedCategories];
    self.placesToShow = [self filterPlaces:self.places usingCategories:selectedCategories];
}

- (NSArray *)selectedCategories {
    
    if(!_selectedCategories) {
        _selectedCategories = [[SWPCategoryStore sharedInstance] selectedCategories];
    }
    
    return _selectedCategories;
}

- (void)setPlacesToShow:(NSArray *)placesToShow
{
    _placesToShow = placesToShow;
    if(placesToShow.count == 0) {
        self.tableView.hidden = YES;
        self.infoView.hidden = NO;
    }else{
        self.tableView.hidden = NO;
        self.infoView.hidden = YES;
    }
    [self.tableView reloadData];
}

- (SWPLoadingViewController *)loadingViewController {
    if(!_loadingViewController) {
        _loadingViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loadingViewController"];
    }
    return _loadingViewController;
}

- (SWPSlidingMenuViewController *)slidingMenu {
    if(!_slidingMenu) {
        _slidingMenu = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SlidingMenuViewController"];
    }
    return _slidingMenu;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UI appearance
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [SWPThemeHelper colorForNavigationBar];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    //Navigation Item title view
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [titleView addSubview:[[UIImageView alloc ] initWithImage:[UIImage imageNamed:@"SwipperLogo"]]];
    self.navigationItem.titleView = titleView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppStateTransition) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppStateTransition) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.placesToShow.count == 0) {
        self.tableView.hidden = YES;
        self.infoView.hidden = NO;
    }else{
        self.tableView.hidden = NO;
        self.infoView.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if(self.loadingViewController.isBeingPresented) {
        [self.loadingViewController hideLoadingViewControllerAnimated:YES];
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

- (IBAction)showMapTouched:(UIBarButtonItem *)sender {
    [self.delegate didDismissListViewController:self];
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

- (IBAction)howToArriveButtonTapped:(UIButton *)sender {

    if([sender.superview.superview isKindOfClass:[SWPPlaceTableViewCell class]]) {
        SWPPlaceTableViewCell *cell = (SWPPlaceTableViewCell *)sender.superview.superview;
        id<SWPPlace> place = cell.place;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[place placeCoordinate].latitude longitude:[place placeCoordinate].longitude];
        
        self.loadingViewController.message = @"Launching maps app";
        self.loadingViewController.showSpinner = YES;
        [self.loadingViewController presentLoadingViewControllerInViewController:self andView:self.view animated:YES];
        
        self.menuBarButtonItem.enabled = NO;
        self.mapBarButtonItem.enabled = NO;
     
        [[JSNetworkActivityIndicatorManager sharedManager] startActivity];
        
        __weak SWPListViewController *weakSelf = self;
        
        [[[CLGeocoder alloc] init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            
            [[JSNetworkActivityIndicatorManager sharedManager] endActivity];
            
            if (weakSelf.isViewLoaded && weakSelf.view.window) {
                if(!error) {
                    //launching maps app
                    MKMapItem *destinationMapItem = [[MKMapItem alloc] initWithPlacemark:placemarks.firstObject];
                    NSArray *mapItems = [NSArray arrayWithObject:destinationMapItem];
                    NSDictionary *launchOptions = [NSDictionary dictionaryWithObject:MKLaunchOptionsDirectionsModeWalking forKey:MKLaunchOptionsDirectionsModeKey];
                    [MKMapItem openMapsWithItems:mapItems launchOptions:launchOptions];
                    
                } else {
                    //show error and hide loading vc
                    self.loadingViewController.message = @"Error loading address";
                    self.loadingViewController.showSpinner = NO;
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        weakSelf.menuBarButtonItem.enabled = YES;
                        weakSelf.mapBarButtonItem.enabled = YES;
                        [self.loadingViewController hideLoadingViewControllerAnimated:YES];
                    });
                }
            }
        }];
    }
}

#pragma mark - Event handling

- (void)handleAppStateTransition {
    if(self.loadingViewController.isBeingPresented) {
        [self.loadingViewController hideLoadingViewControllerAnimated:NO];
        self.menuBarButtonItem.enabled = YES;
        self.mapBarButtonItem.enabled = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.placesToShow.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SWPPlaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeCell" forIndexPath:indexPath];
    
    id<SWPPlace> place = [self.placesToShow objectAtIndex:indexPath.row];
    
    cell.place = place;
    
    CLLocation *startLocation = self.userLocation.location;
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:[place placeCoordinate].latitude longitude:[place placeCoordinate].longitude];
    CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];
    
    [cell.placeDistanceLabel setText:[NSString stringWithFormat:@"%.1f km",distance / 1000]];
    
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SWPPlaceTableViewCell *touchedCell = (SWPPlaceTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    self.selectedPlace = touchedCell.place;
    
    [self performSegueWithIdentifier:@"showDetailsFromList" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    double placeNameAndInsetsHeight = 43;
    
    id<SWPPlace> place = [self.placesToShow objectAtIndex:indexPath.row];
    
    //(magic number?) 99.5 seems to be the width of category icon on the left plus how to arrive icon on the right
    
    CGSize constrainedSize = CGSizeMake(self.view.frame.size.width - 99.5, 999);
    
    NSDictionary *placeAddressAtributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"HelveticaNeue" size:14.0], NSFontAttributeName,
                                         nil];
    
    NSMutableAttributedString *placeAddressString = [[NSMutableAttributedString alloc] initWithString:place.placeAddress attributes:placeAddressAtributes];
    
    NSMutableAttributedString *placeCityString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@, %@",place.placeCity,place.placeState,place.placeCountry] attributes:placeAddressAtributes];
    
    CGRect placeAddressRect = [placeAddressString boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGRect placeCityRect = [placeCityString boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return placeNameAndInsetsHeight + placeAddressRect.size.height + placeCityRect.size.height;
}

#pragma mark - SWPSlidingMenuViewControllerDelegate implementation

- (void)slidingMenuViewController:(SWPSlidingMenuViewController *)sender userDidSelectCategories:(NSArray *)selectedCategories
{
    self.selectedCategories = selectedCategories;
    [self.slidingMenu hideAnimated:YES];
}

- (void)didShowSlidingMenuViewController:(SWPSlidingMenuViewController *)sender {
    self.mapBarButtonItem.enabled = NO;
}

- (void)didHideSlidingMenuViewController:(SWPSlidingMenuViewController *)sender {
    self.mapBarButtonItem.enabled = YES;
}

#pragma mark - Places filtering

- (NSArray *)filterPlaces:(NSArray *)places usingCategories:(NSArray *)selectedCategories {
    
    NSMutableArray *filteredPlaces = [NSMutableArray arrayWithCapacity:places.count];
    
    for (id<SWPPlace> place in places) {
        
        NSUInteger index =[selectedCategories indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj conformsToProtocol:@protocol(SWPCategory)])
            {
                id<SWPCategory> category = (id<SWPCategory>) obj;
                if([place.placeCategory isEqualToString:category.categoryName]) return YES;
            }
            return NO;
        }];
        
        if(index != NSNotFound)
        {
            [filteredPlaces addObject:place];
        }
    }
    
    return filteredPlaces;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showDetailsFromList"]) {
        UIViewController *dvc= segue.destinationViewController;
        if([dvc isKindOfClass:[SWPDetailsViewController class]]) {
            SWPDetailsViewController *detailsViewController = (SWPDetailsViewController *)dvc;
            detailsViewController.userLocation = self.userLocation;
            detailsViewController.place = self.selectedPlace;
        }
    }
}

@end
