//
//  SWPListViewController.m
//  swipper
//
//  Created by Fer Rowies on 10/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPListViewController.h"
#import "SWRevealViewController.h"
#import "SWPThemeHelper.h"
#import "SWPPlace.h"
#import "SWPPlaceTableViewCell.h"

@interface SWPListViewController ()

@property (nonatomic, strong, readwrite) NSArray *selectedCategories;

@end

@implementation SWPListViewController

#pragma mark - Getters/Setters

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    [self.tableView reloadData];
}

- (void)setSelectedCategories:(NSArray *)selectedCategories
{
    _selectedCategories = selectedCategories;
    [self.tableView reloadData];
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UI appearance
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [SWPThemeHelper colorForNavigationBar];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //setting self as menuViewController delegate
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)showMenu
{
    SWRevealViewController *revealController = [self revealViewController];
    [revealController revealToggleAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SWPPlaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeCell" forIndexPath:indexPath];
    id<SWPPlace> place = [self.places objectAtIndex:indexPath.row];
    cell.placeNameLabel.text = place.placeName;
    cell.placeAddressLabel.text = place.placeAddress;
    cell.placeCityLabel.text = [NSString stringWithFormat:@"%@, %@, %@",place.placeCity,place.placeState,place.placeCountry];
    cell.listIconImageView.backgroundColor = [SWPThemeHelper colorForCategoryName:place.placeCategory];
    cell.listIconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@CellImage",place.placeCategory]];
    //add distance info
    return cell;
}

#pragma mark - SWPMenuViewController implementation

- (void)menuViewController:(SWPMenuViewController *)sender userDidSelectCategories:(NSArray *)selectedcategories
{
    self.selectedCategories = selectedcategories;
    [[self revealViewController] setFrontViewPosition:FrontViewPositionLeft animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
