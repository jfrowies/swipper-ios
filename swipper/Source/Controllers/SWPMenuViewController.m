//
//  SWPMenuViewController.m
//  swipper
//
//  Created by fernando rowies on 9/10/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPMenuViewController.h"
#import "SWPCategory.h"
#import "SWPCategoryStore.h"
#import "SWPCategoryTableViewCell.h"
#import "SWPApplyTableViewCell.h"
#import "SWPAllCategoriesTableViewCell.h"
#import "SWPThemeHelper.h"

@interface SWPMenuViewController ()

@end

@implementation SWPMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //UI appearance
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [SWPThemeHelper colorForNavigationBar];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //fetch categories from singleton
    //disgusting, I know.
    self.placesCategories = [[SWPCategoryStore sharedInstance] placesCategories];
    self.selectedCategories = [[SWPCategoryStore sharedInstance] selectedCategories];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2 + self.placesCategories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        SWPAllCategoriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allCategoriesCell" forIndexPath:indexPath];
        
        if(self.placesCategories.count == self.selectedCategories.count)
            cell.allCategoriesSwitch.on = YES;
        else
            cell.allCategoriesSwitch.on = NO;
        
        [cell.allCategoriesSwitch addTarget:self action:@selector(allCategoriesSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    
    if(indexPath.row > 0 && indexPath.row <= self.placesCategories.count)
    {
        SWPCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
        id<SWPCategory> category = [self.placesCategories objectAtIndex:indexPath.row-1];
        cell.categoryName.text = category.categoryName;
        cell.categoryColorView.backgroundColor = [SWPThemeHelper colorForCategory:category];
        if([self.selectedCategories indexOfObjectIdenticalTo:category] == NSNotFound)
            cell.categorySwitch.on = NO;
        else
            cell.categorySwitch.on = YES;
        [cell.categorySwitch addTarget:self action:@selector(categorySwitchChanged:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    
    if(indexPath.row >= self.placesCategories.count)
    {
        SWPApplyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"applyCell" forIndexPath:indexPath];
        [cell.applyButton addTarget:self action:@selector(applyButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return nil;
}

#pragma mark - Actions

- (void)allCategoriesSwitchChanged:(id)sender
{
    if(sender != nil && [sender isKindOfClass:[UISwitch class]])
    {
        UISwitch *allCategoriesSwitch= (UISwitch *)sender;
        for (int i=1; i<=self.placesCategories.count; i++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if(cell != nil && [cell isKindOfClass:[SWPCategoryTableViewCell class]])
            {
                SWPCategoryTableViewCell *categoryCell = (SWPCategoryTableViewCell *)cell;
                [categoryCell.categorySwitch setOn:allCategoriesSwitch.on animated:YES];
            }
        }
    }
}

- (void)categorySwitchChanged:(id)sender
{
    bool allOn = true;
    
    //nasty, but...
    for (int i=1; i<=self.placesCategories.count; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if(cell != nil && [cell isKindOfClass:[SWPCategoryTableViewCell class]])
        {
            SWPCategoryTableViewCell *categoryCell = (SWPCategoryTableViewCell *)cell;
            if(![categoryCell.categorySwitch isOn])
                allOn = false;
        }
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if(cell != nil && [cell isKindOfClass:[SWPAllCategoriesTableViewCell class]])
    {
        SWPAllCategoriesTableViewCell *allCategoriesCell = (SWPAllCategoriesTableViewCell *)cell;
        if(allOn)
           [allCategoriesCell.allCategoriesSwitch setOn:YES animated:YES];
        else
            [allCategoriesCell.allCategoriesSwitch setOn:NO animated:YES];
    }
}

- (void)applyButtonTouched:(id)sender
{
    NSMutableArray *selectedCategories = [NSMutableArray array];
    
    //obtain the selected categories
    for (int i=1; i<=self.placesCategories.count; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if(cell != nil && [cell isKindOfClass:[SWPCategoryTableViewCell class]])
        {
            SWPCategoryTableViewCell *categoryCell = (SWPCategoryTableViewCell *)cell;
            if([categoryCell.categorySwitch isOn])
            {
                [selectedCategories addObject:[self.placesCategories objectAtIndex:i-1]];
            }
        }
    }
    
    [[SWPCategoryStore sharedInstance] setSelectedCategories:selectedCategories];
    [self.delegate menuViewController:self userDidSelectCategories:selectedCategories];
}

@end
