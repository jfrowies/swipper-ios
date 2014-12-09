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
#import "M13Checkbox+Menu.h"
#import "SWPSimpleCategory.h"
#import "NSMutableArray+UniqueElements.h"

@interface SWPMenuViewController ()
@property (nonatomic, strong) NSMutableArray *selectedCategories;
@end

@implementation SWPMenuViewController

#pragma mark - View life cycle

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
    self.placesCategories = [[SWPCategoryStore sharedInstance] placesCategories];
    self.selectedCategories = [[[SWPCategoryStore sharedInstance] selectedCategories] mutableCopy];
    
    [self.tableView reloadData];
    [self setApplyButtonEnabled:YES];
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
        
        [cell setCheckBox:[M13Checkbox checkboxForMenu]];
        
        if(self.placesCategories.count == self.selectedCategories.count)
            cell.checkBox.checkState = YES;
        else
            cell.checkBox.checkState = NO;
        
        [cell.checkBox addTarget:self action:@selector(allCategoriesSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    
    if(indexPath.row > 0 && indexPath.row <= self.placesCategories.count)
    {
        SWPCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
        
        id<SWPCategory> category = [self.placesCategories objectAtIndex:indexPath.row-1];
        
        cell.category = category;

        [cell setCheckBox:[M13Checkbox checkboxForMenu]];
        if([self.selectedCategories indexOfObject:category] == NSNotFound)
             cell.checkBox.checkState = NO;
        else
             cell.checkBox.checkState = YES;
        
        [cell.checkBox addTarget:self action:@selector(categorySwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
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

#pragma mark - Enable/Disable apply button

- (void)setApplyButtonEnabled:(BOOL)enabled
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.placesCategories.count+1 inSection:0]];
    if(cell != nil && [cell isKindOfClass:[SWPApplyTableViewCell class]])
    {
        SWPApplyTableViewCell *applyCell = (SWPApplyTableViewCell *)cell;
        applyCell.applyButton.enabled = enabled;
        if(enabled)
            [applyCell.applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        else
            [applyCell.applyButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

#pragma mark - Table view delegate implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([cell isKindOfClass:[SWPAllCategoriesTableViewCell class]]) {
        SWPAllCategoriesTableViewCell *allCategoriesCell = (SWPAllCategoriesTableViewCell *)cell;
        allCategoriesCell.checkBox.checkState = !allCategoriesCell.checkBox.checkState;
        [self allCategoriesSwitchChanged:allCategoriesCell.checkBox];
    }
    
    if([cell isKindOfClass:[SWPCategoryTableViewCell class]]) {
        SWPCategoryTableViewCell *categoryCell = (SWPCategoryTableViewCell *)cell;
        categoryCell.checkBox.checkState = !categoryCell.checkBox.checkState;
        [self categorySwitchChanged:categoryCell.checkBox];
    }

}

#pragma mark - Turn on/off AllCategoriesSwitch

- (void)setAllCategoriesSwitchOn:(BOOL)on
{
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if(cell != nil && [cell isKindOfClass:[SWPAllCategoriesTableViewCell class]])
    {
        SWPAllCategoriesTableViewCell *allCategoriesCell = (SWPAllCategoriesTableViewCell *)cell;
        if(on)
            [allCategoriesCell.checkBox setCheckState:YES];
        else
            [allCategoriesCell.checkBox setCheckState:NO];
    }
}

#pragma mark - Actions

- (void)allCategoriesSwitchChanged:(id)sender
{
    if(sender != nil && [sender isKindOfClass:[M13Checkbox class]])
    {
        M13Checkbox *allCategoriesSwitch= (M13Checkbox *)sender;
        
        if(allCategoriesSwitch.checkState) {
            self.selectedCategories = [self.placesCategories mutableCopy];
        }else {
            self.selectedCategories = [NSMutableArray array];
        }
        
        // disable/enable all switches
        for (int i=1; i<=self.placesCategories.count; i++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if(cell != nil && [cell isKindOfClass:[SWPCategoryTableViewCell class]])
            {
                SWPCategoryTableViewCell *categoryCell = (SWPCategoryTableViewCell *)cell;
                [categoryCell.checkBox setCheckState:allCategoriesSwitch.checkState];
            }
        }
        
        //disable enable apply button
        [self setApplyButtonEnabled:allCategoriesSwitch.checkState];
    }
}

- (void)categorySwitchChanged:(id)sender
{
    BOOL allOn = YES;
    BOOL allOff = YES;
    
    for (int i=1; i<=self.placesCategories.count; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if(cell != nil && [cell isKindOfClass:[SWPCategoryTableViewCell class]])
        {
            SWPCategoryTableViewCell *categoryCell = (SWPCategoryTableViewCell *)cell;
            if(categoryCell.checkBox.checkState == YES) {
                [self.selectedCategories addObjectIfNoExist:categoryCell.category];
                allOff = NO;
            }
            else {
                [self.selectedCategories removeObject:categoryCell.category];
                allOn = NO;
            }
        }
    }
    
    [self setAllCategoriesSwitchOn:allOn];
    [self setApplyButtonEnabled:!allOff];
}

- (void)applyButtonTouched:(id)sender
{
    [self.delegate menuViewController:self userDidSelectCategories:self.selectedCategories];
}

@end
