//
//  SWPMessageBarViewController.m
//  swipper
//
//  Created by Fer Rowies on 12/9/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPMessageBarViewController.h"

@interface SWPMessageBarViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *messageBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBarTopSpace;

@end

@implementation SWPMessageBarViewController

#define messageBarTopSpaceConstantShow 0.0f
#define messageBarTopSpaceConstantHide -30.0f

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.messageBarTopSpace.constant = messageBarTopSpaceConstantHide;
//    self.isShowingMessage = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Show/Hide Message

- (void)showMessage:(NSString *)message withBarType:(MessageBarType)barType animated:(BOOL)animated {
    self.message = message;
    self.messageBarType = barType;
    
    [self.messageLabel setText:message];
    
    [self.view bringSubviewToFront:self.messageBarView];
    
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
    
    
//    switch (barType) {
//        case MessageBarInfo:
//            self.messageBarView.backgroundColor = [UIColor yellowColor];
//            break;
//        case MessageBarWarning:
//            self.messageBarView.backgroundColor = [UIColor orangeColor];
//            break;
//        case MessageBarError:
//            self.messageBarView.backgroundColor = [UIColor redColor];
//            break;
//        default:
//            break;
//    }
    
//    self.messageBarTopSpace.constant = messageBarTopSpaceConstantShow;
//    
//    if(animated) {
//        [UIView animateWithDuration:0.2f animations:^{
//            [self.view layoutIfNeeded];
//        }];
//    }else {
//        [self.view layoutIfNeeded];
//    }
    
    self.isShowingMessage = YES;
}

- (void)hideMessageAnimated:(BOOL)animated {
    
//    self.messageBarTopSpace.constant = messageBarTopSpaceConstantHide;
//    
//    if(animated) {
//        [UIView animateWithDuration:0.2f animations:^{
//            [self.view layoutIfNeeded];
//        }];
//    }else {
//        [self.view layoutIfNeeded];
//    }
    
    self.isShowingMessage = NO;
}

@end
