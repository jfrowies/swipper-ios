//
//  SWPAllCategoriesTableViewCell.m
//  swipper
//
//  Created by fernando rowies on 9/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPAllCategoriesTableViewCell.h"

@interface SWPAllCategoriesTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@end

@implementation SWPAllCategoriesTableViewCell

#pragma mark - getters/setters

- (void)setCheckBox:(M13Checkbox *)checkBox {
    _checkBox = checkBox;
    [self.checkMarkView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.checkMarkView addSubview:_checkBox];
}

#pragma mark - 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
