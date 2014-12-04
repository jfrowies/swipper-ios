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

@interface SWPListViewController ()

@property (nonatomic, strong, readwrite) NSArray *selectedCategories;
@property (nonatomic, strong) SWPSlidingMenuViewController *slidingMenu;
@property (nonatomic, strong) NSArray *placesToShow;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    [self.tableView reloadData];
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UI appearance
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [SWPThemeHelper colorForNavigationBar];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.slidingMenu = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SlidingMenuViewController"];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

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
        
        SWPLoadingViewController *loadingViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loadingViewController"];
        self.menuBarButtonItem.enabled = NO;
        self.mapBarButtonItem.enabled = NO;
        [self addChildViewController:loadingViewController];
        [self.view addSubview:loadingViewController.view];
        
        [[[CLGeocoder alloc] init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if(!error) {
                MKMapItem *destinationMapItem = [[MKMapItem alloc] initWithPlacemark:placemarks.firstObject];
                NSArray *mapItems = [NSArray arrayWithObject:destinationMapItem];
                NSDictionary *launchOptions = [NSDictionary dictionaryWithObject:MKLaunchOptionsDirectionsModeWalking forKey:MKLaunchOptionsDirectionsModeKey];
                [MKMapItem openMapsWithItems:mapItems launchOptions:launchOptions];
                self.menuBarButtonItem.enabled = YES;
                self.mapBarButtonItem.enabled = YES;
                [loadingViewController removeFromParentViewController];
                [loadingViewController.view removeFromSuperview];
            } else {
                //TODO: inform error to the user
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

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

#pragma mark - SWPSlidingMenuViewControllerDelegate implementation

- (void)slidingMenuViewController:(SWPSlidingMenuViewController *)sender userDidSelectCategories:(NSArray *)selectedCategories
{
    self.selectedCategories = selectedCategories;
    [self.slidingMenu hideAnimated:YES];
}

- (void)didShowSlidingMenuViewController:(SWPSlidingMenuViewController *)sender {
    self.mapBarButtonItem.enabled = NO;
    [UIView animateWithDuration:0.2f animations:^{
        self.tableView.alpha = 0.5f;
    }];
}

- (void)didHideSlidingMenuViewController:(SWPSlidingMenuViewController *)sender {
    self.mapBarButtonItem.enabled = YES;
    [UIView animateWithDuration:0.2f animations:^{
        self.tableView.alpha = 1;
    }];
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
    
}

@end
