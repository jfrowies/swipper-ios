//
//  SWPAnnotationView.m
//  swipper
//
//  Created by Fernando Rowies on 12/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPAnnotationView.h"

@implementation SWPAnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    // Get the custom callout view.
    UIView *calloutView = self.calloutView;
    if (selected) {
        CGRect calloutViewFrame = calloutView.frame;
        calloutViewFrame.origin.x = self.bounds.origin.x - 15.0;
        calloutViewFrame.origin.y = self.bounds.origin.y - 60.0;
        calloutView.frame = calloutViewFrame;
        [self addSubview:calloutView];
    } else {
        [calloutView removeFromSuperview];
    }
}


@end
