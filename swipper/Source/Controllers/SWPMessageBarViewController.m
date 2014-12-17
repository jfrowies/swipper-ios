//
//  SWPMessageBarViewController.m
//  swipper
//
//  Created by Fer Rowies on 12/9/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPMessageBarViewController.h"
#import "SWPMessageBarView.h"

@interface SWPMessageBarViewController ()

@property (strong, nonatomic) IBOutlet SWPMessageBarView *barView;

@end

@implementation SWPMessageBarViewController

#define messageBarTopSpaceConstantShow 0.0f
#define messageBarTopSpaceConstantHide -30.0f
#define messageBarHeight 30.0f

#pragma mark - Getters/Setters

- (void)setMessage:(NSString *)message {
    _message = message;
    [self.barView.messageLabel setText:_message];
}

- (void)setMessageBarType:(MessageBarType)messageBarType {
    _messageBarType = messageBarType;
    
//    switch (_messageBarType) {
//        case MessageBarInfo:
//            self.barView.backgroundColor = [UIColor yellowColor];
//            break;
//        case MessageBarWarning:
//            self.barView.backgroundColor = [UIColor orangeColor];
//            break;
//        case MessageBarError:
//            self.barView.backgroundColor = [UIColor redColor];
//            break;
//        default:
//            break;
//    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.messageBarTopSpace.constant = messageBarTopSpaceConstantHide;
//    self.isShowingMessage = NO;
    
    // Instantiate a referenced view (assuming outlet has hooked up in XIB).
    [[NSBundle mainBundle] loadNibNamed:@"SWPMessageBarView" owner:self options:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Show/Hide Message

- (void)showMessage:(NSString *)message withBarType:(MessageBarType)barType animated:(BOOL)animated {
    
    self.message = message;
    self.messageBarType = barType;
    
    if(self.isShowingMessage) return;
    
    [self.barView setFrame:CGRectMake(0.0f, messageBarTopSpaceConstantHide, self.view.frame.size.width, messageBarHeight)];
    [self.view addSubview:self.barView];
    

    if(animated) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.barView setFrame:CGRectMake(0.0f, messageBarTopSpaceConstantShow, self.view.frame.size.width, messageBarHeight)];
            [self.view layoutIfNeeded];
        }];
    }else {
        [self.barView setFrame:CGRectMake(0.0f, messageBarTopSpaceConstantShow, self.view.frame.size.width, messageBarHeight)];
        [self.view layoutIfNeeded];
    }
    
    self.isShowingMessage = YES;
}

- (void)hideMessageAnimated:(BOOL)animated {
    
//    self.messageBarTopSpace.constant = messageBarTopSpaceConstantHide;
    
    if(!self.isShowingMessage) return;
    
    if(animated) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.barView setFrame:CGRectMake(0.0f, messageBarTopSpaceConstantHide, self.view.frame.size.width, messageBarHeight)];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.barView removeFromSuperview];
        }];
    }else {
        [self.barView setFrame:CGRectMake(0.0f, messageBarTopSpaceConstantHide, self.view.frame.size.width, messageBarHeight)];
        [self.view layoutIfNeeded];
        [self.barView removeFromSuperview];
    }
    
    self.isShowingMessage = NO;
}

@end
