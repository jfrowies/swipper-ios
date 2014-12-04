//
//  SWPCategoryTableViewCell.m
//  swipper
//
//  Created by fernando rowies on 9/18/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPCategoryTableViewCell.h"
#import "SWPThemeHelper.h"

@interface SWPCategoryTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UILabel *categoryName;
@property (weak, nonatomic) IBOutlet UIView *categoryColorView;
@end

@implementation SWPCategoryTableViewCell

#pragma mark - getters/setters

- (void)setCheckBox:(M13Checkbox *)checkBox {
    _checkBox = checkBox;
    [self.checkMarkView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.checkMarkView addSubview:_checkBox];
}

- (void)setCategory:(id<SWPCategory>)category {
    _category = category;
    [self.categoryName setText:[category categoryName]];
    self.categoryColorView.backgroundColor = [SWPThemeHelper colorForCategoryName:category.categoryName];
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
