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

@interface SWPListViewController ()

@property (nonatomic, strong, readwrite) NSArray *selectedCategories;
@property (nonatomic, strong) SWPSlidingMenuViewController *slidingMenu;
@property (nonatomic, strong) NSArray *placesToShow;

@end

@implementation SWPListViewController

#pragma mark - Getters/Setters

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    self.placesToShow = [self filterPlaces];
}

- (void)setSelectedCategories:(NSArray *)selectedCategories
{
    _selectedCategories = selectedCategories;
    self.placesToShow = [self filterPlaces];
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
    
    self.selectedCategories = [[SWPCategoryStore sharedInstance] selectedCategories];
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
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height) animated:NO];
        [self.slidingMenu presentSlidingMenuInViewController:self andView:self.view];
        self.slidingMenu.delegate = self;
    }else {
        [self.slidingMenu hide];
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
    cell.placeNameLabel.text = place.placeName;
    cell.placeAddressLabel.text = place.placeAddress;
    cell.placeCityLabel.text = [NSString stringWithFormat:@"%@, %@, %@",place.placeCity,place.placeState,place.placeCountry];
    cell.listIconImageView.backgroundColor = [SWPThemeHelper colorForCategoryName:place.placeCategory];
    cell.listIconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@CellImage",place.placeCategory]];
    //add distance info
    return cell;
}

#pragma mark - SWPSlidingMenuViewControllerDelegate implementation

- (void)slidingMenuViewController:(SWPSlidingMenuViewController *)sender userDidSelectCategories:(NSArray *)selectedCategories
{
    self.selectedCategories = selectedCategories;
    [self.slidingMenu hide];
}

- (void)didShowSlidingMenuViewController:(SWPSlidingMenuViewController *)sender {
    self.tableView.scrollEnabled = NO;
}

- (void)didHideSlidingMenuViewController:(SWPSlidingMenuViewController *)sender {
    self.tableView.scrollEnabled = YES;
}

#pragma mark - Places filtering

- (NSArray *)filterPlaces {
    
    NSMutableArray *filteredPlaces = [NSMutableArray arrayWithCapacity:self.places.count];
    
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
            [filteredPlaces addObject:place];
        }
    }
    
    return filteredPlaces;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
